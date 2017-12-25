<p align="center"><img src="https://raw.githubusercontent.com/RaidAndFade/Haxicord/master/logos/haxicord.png" alt="Haxicord" width="300"></p>
<h1 align="center">Haxicord</h1>

Haxicord is a Discord API wrapper for Haxe.

## Installation
To install the library in your project, use the haxelib package manager:

`haxelib install haxicord`

## Usage
[Normal humans can click here for a proper example of some base features](https://github.com/RaidAndFade/Haxicord/blob/master/src/com/raidandfade/haxicord/test/Test.hx)

Those of a lower level of dedication can use the example below: (Takes advantage of the new command api)

```hx
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
