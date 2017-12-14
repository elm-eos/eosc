const xhr2 = require('xhr2');
global.XMLHttpRequest = xhr2.XMLHttpRequest;

const Elm = require('./Elm');
const app = Elm.Main.worker(process.argv.slice(2).join(' '));
app.ports.stdout.subscribe(s => process.stdout.write(s));
app.ports.stderr.subscribe(s => process.stderr.write(s));
