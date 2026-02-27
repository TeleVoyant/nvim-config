-- Place this file at: ~/.config/nvim/ftplugin/java.lua
-- This ensures it only runs for Java files

local jdtls = require("jdtls")

-- Get the Mason install path
local mason_path = vim.fn.stdpath("data") .. "/mason"
local jdtls_path = mason_path .. "/packages/jdtls"

-- Determine OS
local os_config = "linux"
if vim.fn.has("mac") == 1 then
    os_config = "mac"
elseif vim.fn.has("win32") == 1 then
    os_config = "win"
end

-- Data directory for jdtls (workspace)
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

-- Get jdtls jar
local jar_path = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

-- Java configuration
local java_cmd = "/home/niel/.asdf/installs/java/adoptopenjdk-21.0.9+10.0.LTS/bin/java"

-- jdtls configuration
local config = {
    cmd = {
        java_cmd,
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xmx1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",

        "-jar",
        jar_path,
        "-configuration",
        jdtls_path .. "/config_" .. os_config,
        "-data",
        workspace_dir,
    },

    root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),

    settings = {
        java = {
            eclipse = {
                downloadSources = true,
            },
            configuration = {
                updateBuildConfiguration = "interactive",
                runtimes = {
                    {
                        name = "JavaSE-21",
                        path = "/home/niel/.asdf/installs/java/adoptopenjdk-21.0.9+10.0.LTS",
                    },
                },
            },
            maven = {
                downloadSources = true,
            },
            implementationsCodeLens = {
                enabled = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            references = {
                includeDecompiledSources = true,
            },
            format = {
                enabled = true,
                settings = {
                    url = vim.fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml",
                    profile = "GoogleStyle",
                },
            },
        },
        signatureHelp = { enabled = true },
        completion = {
            favoriteStaticMembers = {
                "org.hamcrest.MatcherAssert.assertThat",
                "org.hamcrest.Matchers.*",
                "org.hamcrest.CoreMatchers.*",
                "org.junit.jupiter.api.Assertions.*",
                "java.util.Objects.requireNonNull",
                "java.util.Objects.requireNonNullElse",
                "org.mockito.Mockito.*",
            },
            importOrder = {
                "java",
                "javax",
                "com",
                "org",
            },
        },
        extendedClientCapabilities = jdtls.extendedClientCapabilities,
        sources = {
            organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
            },
        },
        codeGeneration = {
            toString = {
                template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
            },
            useBlocks = true,
        },
    },

    flags = {
        allow_incremental_sync = true,
    },

    init_options = {
        bundles = {},
    },
}

-- Start or attach to jdtls
-- jdtls.start_or_attach(config)
