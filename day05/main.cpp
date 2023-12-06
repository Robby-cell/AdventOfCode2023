#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include <algorithm>
#include <numeric>

#include "./input"

using std::size_t;
using ulong = unsigned long;

std::string &currentChunk = input;

struct FT {
    ulong toStart;
    ulong fromStart;
    ulong range;

    FT(std::string const &line) {
        ulong to, from, r;

        // yes, sscanf, who cares
        sscanf(line.c_str(), "%ld %ld %ld", &to, &from, &r);

        toStart = to;
        fromStart = from;
        range = r;
    }

    bool isIn(ulong from) {
        return (from >= fromStart)
            and (from < fromStart + range);
    }
    ulong getVal(ulong from) {
        return from + toStart - fromStart;
    }
};

static auto nextBlock(std::vector<FT> &) -> void;
static auto transform(std::vector<ulong> &, std::vector<FT> &) -> void;

auto main(void) -> int {
    std::vector<ulong> seeds;

    std::vector<FT> sts;
    std::vector<FT> stf;
    std::vector<FT> ftw;
    std::vector<FT> wtl;
    std::vector<FT> ltt;
    std::vector<FT> tth;
    std::vector<FT> htl;

    size_t idx = currentChunk.find_first_of(':', 0) + 2;
    currentChunk = currentChunk.substr(idx);

    {
        std::stringstream ss{ currentChunk };
        ulong number;
        while (ss >> number) {
            seeds.push_back(number);
        }
    }

    // too lazy to figure this out so i will fix the oob like this
    try {
        nextBlock(sts);
        nextBlock(stf);
        nextBlock(ftw);
        nextBlock(wtl);
        nextBlock(ltt);
        nextBlock(tth);
        nextBlock(htl);
    } catch (...) {
    }

    transform(seeds, sts);
    transform(seeds, stf);
    transform(seeds, ftw);
    transform(seeds, wtl);
    transform(seeds, ltt);
    transform(seeds, tth);
    transform(seeds, htl);

    ulong min = std::min_element(std::begin(seeds), std::end(seeds))[0];
    std::cout << min << std::endl;

    return 0;
}

static auto transform(std::vector<ulong> &initial, std::vector<FT> &mappings) -> void {
    for (auto in = std::begin(initial); in != std::end(initial); ++in) {
        for (auto mp = std::begin(mappings); mp != std::end(mappings); ++mp) {
            if (mp->isIn(*in)) {
                *in = mp->getVal(*in);
                break;
            }
        }
    }
}

static auto nextBlock(std::vector<FT> &vector) -> void {
    // Move it to after the next colon.
    currentChunk = currentChunk.substr(currentChunk.find_first_of(':', 0) + 2);
    std::string currentLine;

    size_t start = 0;

    while (true) {
        size_t nextNewLine;
        nextNewLine = currentChunk.substr(start).find_first_of('\n', 0);

        currentLine = currentChunk.substr(start, nextNewLine);
        if (currentLine.length() < 1) break;

        start += currentLine.length() + 1;

        FT obj(currentLine);
        vector.push_back(std::move(obj));
    }

    currentChunk = currentChunk.substr(start);
}
