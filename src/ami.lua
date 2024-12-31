return {
    title = 'tezpeak',
    commands = {
        info = {
            description = "ami 'info' sub command",
            summary = 'Prints runtime info and status of the app',
            action = '__tezpeak/info.lua',
            contextFailExitCode = EXIT_APP_INFO_ERROR
        },
        setup = {
            options = {
                configure = {
                    description = 'Configures application, renders templates and installs services'
                }
            },
            action = function(options, _, _, _)
                local no_options = #table.keys(options) == 0
                if no_options or options.environment then
                    am.app.prepare()
                end

                if no_options or not options['no-validate'] then
                    am.execute('validate', { '--platform' })
                end

                if no_options or options.app then
                    am.execute_extension('__xtz/download-binaries.lua', { contextFailExitCode = EXIT_SETUP_ERROR })
                end

                if no_options and not options['no-validate'] then
                    am.execute('validate', { '--configuration' })
                end

                if no_options or options.configure then
                    am.execute_extension('__xtz/create_user.lua', { contextFailExitCode = EXIT_APP_CONFIGURE_ERROR })
                    am.app.render()
                    am.execute_extension('__tezpeak/configure.lua', { contextFailExitCode = EXIT_APP_CONFIGURE_ERROR })
                end
                log_success('tezpeak setup complete.')
            end
        },
        start = {
            description = "ami 'start' sub command",
            summary = 'Starts the tezpeak services',
            action = '__tezpeak/start.lua',
            contextFailExitCode = EXIT_APP_START_ERROR
        },
        stop = {
            description = "ami 'stop' sub command",
            summary = 'Stops the tezpeak services',
            action = '__tezpeak/stop.lua',
            contextFailExitCode = EXIT_APP_STOP_ERROR
        },
        validate = {
            description = "ami 'validate' sub command",
            summary = 'Validates app configuration and platform support',
            action = function(_options, _, _, cli)
                if _options.help then
                    am.print_help(cli)
                    return
                end
                log_success('tezpeak app configuration validated.')
            end
        },
        ["autodetect-configuration"] = {
            description = "ami 'autodetect-configuration' sub command",
            summary = 'Auto detects the configuration of the app',
            options = {
                ["force"] = {
                    aliases = { "f" },
                    description = "Forces auto-detection even if configuration file exists.",
                    type = "boolean"
                },
                ["root"] = {
                    description = "directory where are the apps to detect stored.",
                    type = "string"
                }
            },
            action = function(options, _, _, _)
                if fs.exists('config.hjson') then
                    if not options.force then
                        log_warn('Configuration file already exists. Skipping auto-detection.')
                        return
                    else
                        log_warn('Configuration file already exists. Will be renamed to config.hjson.bak')
                        if not os.rename('config.hjson', 'config.hjson.bak') then 
                            log_error('Failed to rename configuration file. Aborting auto-detection. Please rename the file manually and try again.')
                            return
                        end
                    end
                end
                local result = am.execute_external('bin/tezpeak', {}, { injectArgs = { "--root-dir", options.root or '..', "--autodetect-configuration", "config.hjson" } })
                ami_assert(result == 0, "Failed to auto-detect configuration", EXIT_APP_INTERNAL_ERROR)
            end,
            contextFailExitCode = EXIT_APP_INTERNAL_ERROR
        },
        log = {
            description = "ami 'log' sub command",
            summary = 'Prints logs from services.',
            options = {
                ["follow"] = {
                    aliases = { "f" },
                    description = "Keeps printing the log continuously.",
                    type = "boolean"
                },
                ["end"] = {
                    aliases = { "e" },
                    description = "Jumps to the end of the log.",
                    type = "boolean"
                }
            },
            type = "no-command",
            action = '__tezpeak/log.lua',
            contextFailExitCode = EXIT_APP_INTERNAL_ERROR
        },
        about = {
            description = "ami 'about' sub command",
            summary = 'Prints information about application',
            action = function(options, _, _, _)
                local ok, about_raw = fs.safe_read_file('__tezpeak/about.hjson')
                ami_assert(ok, 'Failed to read about file!', EXIT_APP_ABOUT_ERROR)

                local ok, about = hjson.safe_parse(about_raw)
                about['App Type'] = am.app.get({ 'type', 'id' }, am.app.get('type'))
                ami_assert(ok, 'Failed to parse about file!', EXIT_APP_ABOUT_ERROR)
                if am.options.OUTPUT_FORMAT == 'json' then
                    print(hjson.stringify_to_json(about, { indent = false, skipkeys = true }))
                else
                    print(hjson.stringify(about))
                end
            end
        },
        remove = {
            index = 7,
            action = function(options, _, _, _)
                if options.all then
                    am.execute_extension('__tezpeak/remove-all.lua', { contextFailExitCode = EXIT_RM_ERROR })
                    am.app.remove(require "__tezpeak/constants".protected_files)
                    log_success('Application removed.')
                else
                    log_warn "only whole tezpeak ami instance can be remoced and requires --all parameter"
                end
                return
            end
        },
        version = {
            description = "ami 'version' sub command",
            summary = 'shows ami tezpeak and tezpeak versions',
            action = '__tezpeak/version.lua',
            contextFailExitCode = EXIT_APP_ABOUT_ERROR
        }
    }
}
