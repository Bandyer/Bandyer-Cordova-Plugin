const path = require('path');
const typeStructureTransformer = require('@bandyer/ts-transformer-type-structure/transformer').default;

module.exports = {
    mode: "production",
    entry: {
        main: ['./www/src/BandyerPlugin.ts']
    },

    // Enable sourcemaps for debugging webpack's output.
    //devtool: "source-map",
    resolve: {
        extensions: [".webpack.js", ".web.js", ".ts", ".tsx", ".js"],
        symlinks: true
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
                test: /\.js$/,
                loader: 'babel-loader',
                options: {
                    configFile: path.resolve('babel.config.js')
                },
                include: [
                    path.resolve('www/src')
                ]
            },
            {
                test: /\.js$/,
                loader: 'babel-loader',
                options: {
                    configFile: path.resolve('commonjs-babel.config.js')
                },
                include: [
                    path.resolve('node_modules/typescript-is')
                ]
            },
            // All output '.js' files will have any sourcemaps re-processed by 'source-map-loader'.
            // {
            //     enforce: "pre",
            //     test: /\.js$/,
            //     loader: "source-map-loader"
            // },
            {
                test: /\.tsx?$/,
                loader: "awesome-typescript-loader",
                options: {
                    compiler: 'ttypescript',
                    getCustomTransformers: program => ({
                        before: [typeStructureTransformer(program)]
                    })
                }
            }
        ]
    },
    node: {
        fs: 'empty'
    }
};