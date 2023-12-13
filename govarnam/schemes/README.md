# Language Files

Varnam Language support files. **DOWNLOAD YOUR LANGUAGE FILES FROM [releases](https://github.com/varnamproject/schemes/releases)**.

## Installation

* Download your language support file from [releases](https://github.com/varnamproject/schemes/releases)
* Extract zip
* Open a terminal in your extracted folder
* Run (DO NOT RUN WITH sudo):
```
./install.sh install
```
It will ask for your password, enter it. You will also be asked to import words.

To check if installation is successful, try this command :
```bash
varnamcli -s ml enthaanu
```
It should give malayalam output if installation is successful.

## Development

Folder structure:
- `schemes`
  - ...
  - `ml`
    - `ml.scheme` - Scheme File
    - `symbol-frequency-report.txt` - Symbol Frequency Report
    - `Other folders` - Different pack folders
  - ...
- `install.sh.in` - A placeholder script which will be copied to every scheme folder

### Scheme

A scheme file is a mapping of English characters to Indian language characters. This helps in transliteration using a letter by letter conversion.

The scheme file is compiled to a file called Varnam Symbol Table (VST). Varnam uses VST to do transliteration. **VST IS REQUIRED** for basic language support in Varnam.

[Read more on scheme](https://www.varnamproject.com/docs/adding-a-new-language)

### Symbol Frequency Report

This file is used to populate `weight` column in VST

File format:

```
ക 98
വ 98
അ 98
...
```

This file is made using scripts inside `scripts` folder. It has a README.

### Packs

A language pack is a set of pre-trained **Varnam Learning Files (VLF)** that can be imported into any Varnam instance quickly. It has many words in it. It's basically a dictionary file to import words from.

### Compiling A Scheme

Install dependencies:

```bash
sudo apt install ruby-ffi
```

Compile scheme:

```bash
./compile-scheme.rb -s schemes/ta/ta.scheme -o schemes/ta/ta.vst
```

The compiled scheme will be a SQLite Database with extension ".vst".

Now link the file to the place where Varnam will look for VST.

```bash
sudo ln -s $(realpath schemes/ta/ta.vst) /usr/local/share/varnam/schemes/ta.vst
```

Now Varnam can use it. Test it out :

```bash
varnamcli -s ta nandri
```
