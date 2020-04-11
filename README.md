# Caco

Configure your machines like you develop your web apps

## Usage aka Control Repo

To start using `Caco`, you need a control repo, that is where you add your node config files, keys, certs, whatever makes sense to you.

Create a new `Gemfile` with `bundle init` and add to it:

```ruby
gem 'caco'
```

After you can add your config files under `nodes` folder, with each file being the hostname of your machines:

```
nodes/
  web.example.com.rb
  db.example.com.rb
```

This is the minimum you need to start using Caco, a hello world example would be, in `nodes/<hostname>.rb` add

```ruby
class HelloWorld < Trailblazer::Operation
  step Subprocess(Caco::FileWriter),
    input:  ->(_ctx, **) {{
      path: "/root/caco.txt",
      content: 'Hello World From Caco :)'
    }}
end

HelloWorld.()
```

Sync your control repo to your remote machine and run `./bin/caco` inside its folder, it will create the `/root/caco.txt` file with `Hello World From Caco :)` content

## Data

It's useful to share data between your nodes, you can do this on the `data` folder, you can add yaml files and access inside your config files.

It also has a hierarchy, most specific values overwrite more generic value, files from common to specific are:

- data/common.yaml
- data/<os_name>.yaml
- data/<os_name>/<distro_name>.yaml
- data/nodes/<hostname>.yaml

You can also encrypt values with your keys, for the first time you can create them with `eyaml createkeys` command, you add the files:

- keys/private_key.pkcs7.pem
- keys/public_key.pkcs7.pem

After that you can edit your yaml files with the command `eyaml edit path/to/file.yaml`

It's safe to commit your encrypted yaml files, but remember to never commit your keys, the `keys` folder is also on gitignore.

On your server you also need to sync the `keys` folder to be able to read the values when configuring the nodes.

To read the values, as they are organized as yaml files, considering the structure:

```yaml
# common.yaml
---
prefix:
  name: Common
```

```yaml
# nodes/hostname.yaml
---
prefix:
  name: Hostname
```

(as node file is more specific it overwrites the common.yaml value)

```ruby
Caco::Facter.("prefix", "name")
# => 'Hostname'
```

## Roadmap

- [ ] Bootstrap control repo via CLI
- [ ] Sync remote control repo
- [ ] Run automatically from developer machine
- [ ] Add operations to run as a _health check_ after the config process to ensure it's working as expected (that can also be used as acceptance test in development environment)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Caco project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/fernandes/caco/blob/master/CODE_OF_CONDUCT.md).
