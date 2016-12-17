module.exports = {
    // configuration
    // context: __dirname + "/bin",
    entry: "./bin/enthral.js",
    output: {
        path: __dirname + "/bin",
        filename: "enthral.bundle.js"
    },
    module: {
        noParse: [
            /systemjs/
        ]
    }
};
