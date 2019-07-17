var TypedocWebpackPlugin = require('typedoc-webpack-plugin');

module.exports = {
    mode: "production",
    entry: {
        main: ['./www/src/BandyerPlugin.ts']
    },

    // Enable sourcemaps for debugging webpack's output.
    devtool: "source-map",
    resolve: {
        extensions: ['.ts', '.js']
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
            },
            // All output '.js' files will have any sourcemaps re-processed by 'source-map-loader'.
            {
                enforce: "pre",
                test: /\.js$/,
                loader: "source-map-loader"
            },
            {
                test: /\.tsx?$/,
                loader: "awesome-typescript-loader",
                options: {
                    compiler: 'ttypescript'
                }
            }
        ]
    },
    plugins: [
        new TypedocWebpackPlugin({
            name: 'Bandyer',
            mode: 'file',
            theme: './typedoc-theme/',
            includeDeclarations: false,
            ignoreCompilerErrors: true,
        })
    ],
    node: {
        fs: 'empty'
    }
};