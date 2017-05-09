var path = require('path');

module.exports = {
    entry: {
        polyfills: "./polyfills/polyfills.js",
        enthralerdotcom: "./bin/enthralerdotcom.haxe.js"
    },
    output: {
        path: __dirname + "/bin",
        filename: "[name].bundle.js"
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                loader: 'babel-loader',
                exclude: [path.resolve(__dirname, "node_modules")],
                options: {
                    presets: ['react', 'es2015']
                }
            },
            {
                test: /\.less$/,
                use: [
                    'style-loader',
                    { loader: 'css-loader', options: { importLoaders: 1 } },
                    { loader: 'less-loader', options: { strictMath: true, noIeCompat: true } }
                ]
            }
        ]
    }
};
