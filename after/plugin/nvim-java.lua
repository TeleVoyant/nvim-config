-- ============================================================================
-- nvim-java
-- Java + Spring Boot development support for Neovim.
--
-- nvim-java owns JDTLS setup. Do NOT configure nvim-jdtls separately.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Resolve the JDK already installed on this machine.
--
-- Prefer JAVA_HOME when available. If JAVA_HOME is not set, resolve the
-- actual javac binary and derive the JDK root from it.
-- ---------------------------------------------------------------------------
local java_home = vim.env.JAVA_HOME

if not java_home or java_home == "" then
    local javac = vim.fn.exepath("javac")

    if javac ~= "" then
        java_home = vim.fn.fnamemodify(vim.fn.resolve(javac), ":h:h")
    end
end

-- ---------------------------------------------------------------------------
-- Configure nvim-java.
-- ---------------------------------------------------------------------------
require("java").setup({
    checks = {
        nvim_version = true,
        nvim_jdtls_conflict = true,
    },

    -- you already have Java 25 installed (preferably through version manager like asdf, mise)
    -- if not, set auto_install to true (not recommended, YOU should manage your own java versions)
    -- Setting auto_install=false prevents nvim-java from downloading its own JDK and
    -- makes JDTLS use Java from the current environment.
    jdk = {
        auto_install = false,
        -- version = "25",
    },

    -- Let nvim-java install and manage JDTLS itself.
    jdtls = {
        version = "1.54.0",
    },

    -- Java language/test/debug integrations.
    lombok = {
        enable = true,
        version = "1.18.42",
    },

    java_test = {
        enable = true,
        version = "0.43.2",
    },

    java_debug_adapter = {
        enable = true,
        version = "0.58.3",
    },

    -- Important for AVELA / Spring Boot development.
    spring_boot_tools = {
        enable = true,
        version = "1.55.1",
    },

    log = {
        -- Avoid noisy startup messages in normal use.
        use_console = false,

        -- Keep a file available when something goes wrong.
        use_file = true,
        level = "info",

        log_file = vim.fn.stdpath("state") .. "/nvim-java.log",
        max_lines = 1000,

        show_location = false,
    },
})

-- ---------------------------------------------------------------------------
-- Tell JDTLS explicitly that Java 25 is our project runtime.
--
-- nvim-java installs the base jdtls config above. vim.lsp.config() then
-- augments/overrides that configuration before we enable the server.
-- ---------------------------------------------------------------------------
if java_home and java_home ~= "" then
    vim.lsp.config("jdtls", {
        settings = {
            java = {
                configuration = {
                    runtimes = {
                        {
                            name = "JavaSE-25",
                            path = java_home,
                            default = true,
                        },
                    },
                },
            },
        },
    })
end

-- ---------------------------------------------------------------------------
-- Finally enable JDTLS.
--
-- ORDER MATTERS:
--
--   require("java").setup()
--       ↓
--   vim.lsp.config("jdtls", ...)
--       ↓
--   vim.lsp.enable("jdtls")
-- ---------------------------------------------------------------------------

vim.lsp.enable("jdtls")
