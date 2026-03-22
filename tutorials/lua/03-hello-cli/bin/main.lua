local cli = require("src.hello_cli")
local opts = cli.parse_args(arg)
print(cli.format(opts))
