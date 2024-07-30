### ami-tezpeak

tezpeak ami package

#### Setup

1. Install `ami` if not installed already
    * `wget -q https://raw.githubusercontent.com/alis-is/ami/master/install.sh -O /tmp/install.sh && sudo sh /tmp/install.sh `
2. Create directory for your application (it should not be part of user home folder structure, you can use for example `/bake-buddy/tezpeak`)
3. Create `app.json` or `app.hjson` with app configuration you like, e.g.:
```json
{
    "id": "tezpeak",
    "type": "tzc.tezpeak",
    "user": "<your username>"
}
```
4. Run `sudo ami --path=<your app path> setup`
   * e.g. `ami --path=/bake-buddy/tezpeak` (path is not required if it would be equal to your CWD)
5. Create and configure your config.hjson.
	- your `config.hjson` and other configuration files should be placed next to `app.hjson`
	- refer to [tezpeak readme](https://github.com/tez-capital/tezpeak) for more information about configuration
6. Run `ami --path=<your app path> --help` to investigate available commands
7. Start tezpeak services with `ami --path=<your app path> start`
8. Check info about the tezpeak services `ami --path=<your app path> info`

##### Package configuration change: 
1. `ami --path=<your app path> stop`
2. change app.json or app.hjson as you like
3. `ami --path=<your app path> setup`
4. `ami --path=<your app path> start`

##### Remove app: 
1. `ami --path=<your app path> stop`
2. `ami --path=<your app path> remove --all`

#### Troubleshooting 

Run ami with `-ll=trace` to enable trace level printout, e.g.:
`ami --path=/bake-buddy/tezpeak -ll=trace setup`
