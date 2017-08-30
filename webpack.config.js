var path = require('path');

var ExtractTextPlugin = require("extract-text-webpack-plugin");

module.exports = {
    entry: {
        polyfills: "./polyfills/polyfills.js",
    },
    output: {
        path: __dirname + "/bin/assets",
        publicPath: '/assets/',
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
                test: /\.(sass|css|scss)$/,
                use: ExtractTextPlugin.extract({
                    fallback: "style-loader",
                    use: ["css-loader", "sass-loader"]
                })
            },
        ]
    },
    plugins: [
        new ExtractTextPlugin("styles.css"),
    ],
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
