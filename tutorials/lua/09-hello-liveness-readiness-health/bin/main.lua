local health = require("src.health_checker")
health.init()
print("Health status: " .. health.status())
