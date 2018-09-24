module.exports = {
	chainWebpack: config => {
		config
		.module
		.rule("csv")
		.test(/\.csv$/)
		.use("csv-loader")
		.loader("csv-loader")
		.options({
			dynamicTyping: true,
			header: true,
			skipEmptyLines: true
		})
		.end();
	},

	baseUrl: process.env.NODE_ENV === 'production'
	? '/license-to-kill/'
	: '/'
}