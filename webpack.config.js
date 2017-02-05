module.exports = {
    // configuration
    // context: __dirname + "/bin",
    entry: {
        polyfills: "./polyfills/polyfills.js"
    },
    output: {
        path: __dirname + "/bin",
        filename: "[name].bundle.js"
    },
    module: {}
};
