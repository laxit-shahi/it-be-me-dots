local uv = vim.uv or vim.loop

local M = {}

local fallback_paths = {
  '/opt/rubies/3.4.4/bin',
  '/usr/bin',
}

local bundle_cache = {}
local bundle_notified = {}

local function path_with_fallback()
  local current = vim.env.PATH or os.getenv('PATH') or ''
  local prefix = table.concat(fallback_paths, ':')
  if current == '' then
    return prefix
  end
  return prefix .. ':' .. current
end

local function file_exists(path)
  if not path then
    return false
  end

  local stat = uv.fs_stat(path)
  return stat and stat.type == 'file'
end

local function root_has(root, filenames)
  if not root then
    return nil
  end

  for _, filename in ipairs(filenames) do
    if file_exists(vim.fs.joinpath(root, filename)) then
      return filename
    end
  end

  return nil
end

local function detect_nix(root)
  if vim.fn.executable('nix') ~= 1 then
    return nil
  end

  if root_has(root, { 'flake.nix' }) then
    return { type = 'flake' }
  end

  local nix_file = root_has(root, { 'shell.nix', 'default.nix' })
  if nix_file then
    return { type = 'nix-shell', file = nix_file }
  end

  return nil
end

local function join_output(output)
  if type(output) == 'string' then
    return vim.trim(output)
  end

  if type(output) == 'table' then
    return vim.trim(table.concat(output, '\n'))
  end

  return ''
end

local function ensure_bundle(root)
  if not root then
    return false
  end

  local now = uv.now()
  local cache = bundle_cache[root]
  if cache then
    -- Positive results can be reused for a while; negative ones are retried after a short delay.
    local elapsed = now - cache.timestamp
    if cache.ok and elapsed < 600000 then -- 10 minutes
      return true
    end
    if (not cache.ok) and elapsed < 60000 then -- 60 seconds
      return false
    end
  end

  if vim.fn.executable('bundle') ~= 1 then
    return false
  end

  if not vim.system then
    local escaped_path = vim.fn.shellescape(path_with_fallback())
    local escaped_root = vim.fn.shellescape(root)
    local script = ('export PATH=%s; cd %s && bundle check'):format(escaped_path, escaped_root)
    local output = vim.fn.system({ 'bash', '-lc', script })
    local success = vim.v.shell_error == 0
    bundle_cache[root] = { ok = success, timestamp = uv.now() }
    if not success then
      if not bundle_notified[root] then
        bundle_notified[root] = true
        local message = join_output(output)
        local text = (
          'Ruby tooling disabled for %s. Run `dev up` or `bundle install` to enable Sorbet/RuboCop.'
        ):format(root)
        if message ~= '' then
          text = text .. '\n' .. message
        end
        vim.schedule(function()
          vim.notify(text, vim.log.levels.WARN)
        end)
      end
    else
      bundle_notified[root] = nil
    end
    return success
  end

  local ok, job = pcall(vim.system, { 'bundle', 'check' }, {
    cwd = root,
    env = { PATH = path_with_fallback() },
  })

  if not ok then
    bundle_cache[root] = { ok = false, timestamp = now }
    return false
  end

  local result = job:wait()
  local success = result.code == 0
  bundle_cache[root] = { ok = success, timestamp = uv.now() }

  if not success then
    if not bundle_notified[root] then
      bundle_notified[root] = true
      local stdout, stderr = job:result()
      local message = join_output(stderr)
      if message == '' then
        message = join_output(stdout)
      end
      local text = ('Ruby tooling disabled for %s. Run `dev up` or `bundle install` to enable Sorbet/RuboCop.'):format(root)
      if message ~= '' then
        text = text .. '\n' .. message
      end
      vim.schedule(function()
        vim.notify(text, vim.log.levels.WARN)
      end)
    end
    return false
  end

  bundle_notified[root] = nil
  return true
end

local function build_command(root, opts)
  opts = opts or {}

  local command = vim.deepcopy(opts.command or {})

  local nix = detect_nix(root)
  local has_gemfile = root_has(root, { 'Gemfile', 'gems.rb' }) ~= nil
  local bundle_available = vim.fn.executable('bundle') == 1 or nix ~= nil
  local use_bundle = opts.bundle ~= false and has_gemfile and bundle_available

  if use_bundle and not nix then
    if not ensure_bundle(root) then
      if opts.bundle == 'try' then
        use_bundle = false
      else
        return nil, nil
      end
    end
  end

  if use_bundle then
    table.insert(command, 1, 'exec')
    table.insert(command, 1, 'bundle')
  end

  if nix then
    if nix.type == 'flake' then
      local wrapped = { 'nix', 'develop', root, '--command' }
      vim.list_extend(wrapped, command)
      return wrapped, { PATH = path_with_fallback() }
    end

    if nix.type == 'nix-shell' and nix.file then
      local target = vim.fs.joinpath(root, nix.file)
      return { 'nix-shell', target, '--command', table.concat(command, ' ') },
        { PATH = path_with_fallback() }
    end
  end

  return command, { PATH = path_with_fallback() }
end

function M.rubocop(root)
  return build_command(root, { command = { 'rubocop', '--lsp' }, bundle = true })
end

function M.sorbet(root)
  return build_command(root, {
    command = { 'srb', 'tc', '--lsp', '--disable-watchman' },
    bundle = true,
  })
end

function M.rubocop_formatter(root, filename)
  if not filename or filename == '' then
    return nil
  end

  local target = vim.fn.fnamemodify(filename, ':p')
  local project_root = root or vim.fs.dirname(target)

  local command, env = build_command(project_root, {
    command = {
      'rubocop',
      '-a',
      '--server',
      '-f',
      'quiet',
      '--stderr',
      '--stdin',
      target,
    },
    bundle = 'try',
  })

  if not command then
    return nil
  end

  local executable = command[1]
  local args = {}
  for index = 2, #command do
    args[#args + 1] = command[index]
  end

  return {
    command = executable,
    args = args,
    env = env,
    cwd = project_root,
  }
end

return M
