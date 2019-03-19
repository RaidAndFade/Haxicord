<p align="center"><img src="https://raw.githubusercontent.com/RaidAndFade/Haxicord/master/logos/haxicord.png" alt="Haxicord" width="300"></p>
<h1 align="center">Haxicord</h1>

Haxicord is a Discord API wrapper for Haxe.

[![Haxelib](https://img.shields.io/badge/dynamic/json.svg?label=haxelib&colorB=00bb00&query=version&uri=https%3A%2F%2Fraw.githubusercontent.com%2FRaidAndFade%2FHaxicord%2Fmaster%2Fhaxelib.json)](https://lib.haxe.org/p/Haxicord) [![Discord](https://discordapp.com/api/guilds/419929794957017108/embed.png?style=shield)](https://discord.gg/E338QZH)

## Installation
To install the library in your project, use the haxelib package manager:

`haxelib install haxicord`

## Usage
[Normal humans can click here for a proper example of some base features](https://github.com/RaidAndFade/Haxicord/blob/master/src/com/raidandfade/haxicord/test/Test.hx)

Those of a lower level of dedication can use the example below: (Takes advantage of the command api)

```hx
package;

import com.raidandfade.haxicord.commands.CommandBot;
import com.raidandfade.haxicord.types.Message;

class Main extends CommandBot {

    static function main() {
        new Main("<token>",Main,"-"); //Create an instance of Commandbot with the prefix `-`
    }

    @Command
    function ping(message:Message){
        message.react("✅"); //React to the message with "✅"
        message.reply({content:"Pong!"}); //Send "Pong!" in the same channel
    }
}
```

## Documentation
You can find the documentation [here](https://raidandfade.github.io/Haxicord/)

## Community
Join the Haxicord Discord for more help & to meet others using the library (as well as the dev)
[![Discord](https://discordapp.com/api/guilds/419929794957017108/embed.png?style=banner2)](https://discord.gg/E338QZH)
