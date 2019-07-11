module.exports = {
    source: "./www",
    destination: "./docs",
    excludes: ["types.md.js"],
    plugins: [{
        name: "esdoc-standard-plugin",
        option: {
            unexportedIdentifier: {"enable": true},
            brand: {
                name: "Bandyer",
                logo: "./logo_bandyer.png",
                title: "Bandyer Cordova Plugin",
                description: "This plugin enables cordova users to have chat & audio/video-communication, file sharing, screen-sharing and whiteboard",
                repository: "https://github.com/Bandyer/Bandyer-Cordova-Plugin",
                site: "https://bandyer.com",
                author: "https://twitter.com/bandyerSrl",
                image: "https://static.bandyer.com/corporate/logos/logo_bandyer.png"
            },
            manual: {
                asset: "./manual/asset",
                files: [
                    "./manual/events_emitter.md"
                ]
            }
        }
    }]
};