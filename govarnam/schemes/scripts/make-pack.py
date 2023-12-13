import json
import os
import re
import sys

desc = '''
Usage: script.py <schemeID> <pack-directory>

Example: script.py ml ./ml-basic

Pack JSON file name is pack.json

WordFrequency report file should be word-frequency-report.txt
Pattern file should be patterns.txt
'''

if len(sys.argv) != 3:
    print(desc)
    sys.exit(0)

schemeID = sys.argv[1]
packDir = os.path.realpath(sys.argv[2])

packJSON = os.path.join(packDir, "pack.json")
wordsFile = os.path.join(packDir, "word-frequency-report.txt")
patternsFile = os.path.join(packDir, "patterns.txt")

os.environ["VARNAM_LEARNINGS_DIR"] = packDir

# Learn from frequency report
if os.path.exists(wordsFile):
    os.system("varnamcli -s %s -learn-from-file %s" % (schemeID, wordsFile))

# Learn from patterns
if os.path.exists(patternsFile):
    os.system("varnamcli -s %s -train-from-file %s" % (schemeID, patternsFile))

with open(packJSON, "r") as jsonFile:
    packInfo = json.load(jsonFile)

# Export
os.system("varnamcli -s %s -export %s" % (schemeID, os.path.join(packDir, packInfo["identifier"])))

pageIndex = 1
wordsCount = 0
for v in packInfo["pages"]:
    vlfPath = os.path.join(packDir, v["identifier"] + ".vlf")
    vlfContents = open(vlfPath).read()

    v["page"] = pageIndex
    v["size"] = os.path.getsize(
        vlfPath
    )

    # Gets the first word's confidence
    firstConfidence = re.search(r'c":(.*?),', vlfContents).group(1)
    v["description"] = "Words with confidence lesser than " + firstConfidence

    wordsCount += len(re.findall(r'"c"', vlfContents))
    pageIndex += 1

packInfo["total_words"] = wordsCount
packInfo["pages_count"] = len(packInfo["pages"])

with open(packJSON, "w") as jsonFile:
    json.dump(packInfo, jsonFile, indent=2, ensure_ascii=False)

print("Finished making pack. Hopefully pack.json has the correct number of pages")
