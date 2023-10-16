local packer = require('packer')
packer.util = require('packer.util')

packer.init({
    plugin_package = 'packer', -- The default package for plugins
    preview_updates = true, -- If true, always preview updates before choosing which plugins to update, same as `PackerUpdate --preview`.
    display = {
        open_fn  = require('packer.util').float, -- An optional function to open a window for packer's display
        open_cmd = '65vnew \\[packer\\]', -- An optional command to open a window for packer's display
},
})
