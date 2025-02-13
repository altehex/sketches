import Config
import Logger


config :logger,
  handle_otp_reports: true,
  handle_sasl_reports: true

config :logger, :default_handler,
  level: :debug,
  config: [
	file: ~c'tax_debug.log',
	max_no_bytes: 1_000_000
  ]

config :logger, :default_formatter,
  format: "[$time <$level>] $message\n"

