module.exports = {
    // configuration
    // context: __dirname + "/bin",
    entry: {
        enthral: "./bin/enthral.js",
        polyfills: "./polyfills/polyfills.js"
    },
    output: {
        path: __dirname + "/bin",
        filename: "[name].bundle.js"
    },
    module: {
        noParse: [
            /systemjs/
        ]
    }
};
