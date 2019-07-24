module.exports = function (api) {
    api.cache(true);
    const presets = [
        ["@babel/typescript"],
        ['@babel/preset-env', {

            modules: "commonjs",
            corejs: 3
        }]
    ];
    const plugins = [
        ["@babel/plugin-transform-spread"],
        ['@babel/plugin-transform-runtime', {
            corejs: 3,
            helpers: true,
            regenerator: true,
            useESModules: false
        }]
    ];
    return {
        presets,
        plugins
    }
};