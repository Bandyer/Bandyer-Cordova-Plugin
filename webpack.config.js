module.exports = {
    mode: "production",
    entry: {
        main: ['./www/src/BandyerPlugin.js']
    },
    output: {
        path: __dirname + '/www/out',
        filename: 'bandyer-plugin.min.js',
        library: 'BandyerPlugin',
        libraryTarget: 'umd',
        libraryExport: 'BandyerPlugin',
        umdNamedDefine: true
    },
    module: {
        rules: [
            {
                test: /\.m?js$/,
                exclude: /(node_modules|bower_components)/,
                use: {
                    loader: 'babel-loader'
                }
            }
        ]
    },
    node: {
        fs: 'empty'
    }
};