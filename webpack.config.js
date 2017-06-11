var path = require('path');

module.exports = {
    entry: {
        polyfills: "./polyfills/polyfills.js",
        enthralerdotcom: "./client_enthralerdotcom.hxml"
    },
    output: {
        path: __dirname + "/bin/assets",
        filename: "[name].bundle.js"
    },
    module: {
        rules: [
            {
                test: /\.hxml$/,
                loader: 'haxe-loader',
            },
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
    },
    devServer: {
        contentBase: "./bin",
        overlay: true,
        proxy: {
            "/": {
                changeOrigin: true,
                target: "http://localhost:80"
            }
        },
        publicPath: "/assets/"
    },
};
