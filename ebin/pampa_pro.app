{application, 'pampa_pro', [
	{description, "New project"},
	{vsn, "0.1.0"},
	{modules, ['pampa_pro_app','pampa_pro_sup']},
	{registered, [pampa_pro_sup]},
	{applications, [kernel,stdlib,cowboy,sync,amqp_client]},
	{mod, {pampa_pro_app, []}},
	{env, []}
]}.