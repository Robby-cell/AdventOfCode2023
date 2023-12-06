#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>

// Hold a button for x ms, gives the boat x mm/ms speed for the rest of the race

using u64 = unsigned long long;

std::string fileName = "day06/input.txt";
static auto parseLine(std::string const &, std::vector<u64> &) -> void;
static auto waysToBeat(u64 time, u64 distance) -> u64;

auto main(void) -> int {
    std::string fileContents;
    {
        std::ifstream fs(fileName);
        while (fs.good()) {
            char nextChar = (char)fs.get();
            if (nextChar == EOF)
                break;
            fileContents += nextChar;
        }
    }

    std::vector<u64> time;
    std::vector<u64> distance;

    parseLine(fileContents, time);
    parseLine(fileContents.substr(fileContents.find_first_of('\n', 0) + 1), distance);

    unsigned int ways = 1;
    for (int i = 0; i < time.size(); ++i) {
        ways *= waysToBeat(time[i], distance[i]);
    }

    std::cout << "part 1: " << ways << std::endl;

    u64 trueTime, trueDistance;
    {
        std::stringstream tss;
        for (u64 i = 0; i < time.size(); ++i)
            tss << time[i];

        std::stringstream dss;
        for (u64 i = 0; i < distance.size(); ++i)
            dss << distance[i];

        std::string stime;
        tss >> stime;
        std::string sdist;
        dss >> sdist;

        trueTime = std::stoull(stime);
        trueDistance = std::stoull(sdist);
    }

    u64 wayspart2 = waysToBeat(trueTime, trueDistance);
    std::cout << "part 2: " << wayspart2 << std::endl;
}

static auto waysToBeat(u64 time, u64 distance) -> u64 {
    u64 start, end;
    auto lambda = [&](u64 conv, u64 &modifiee) -> bool {
        u64 dist = conv * (time - conv);
        if (dist > distance) {
            modifiee = conv;
            return true;
        }
        return false;
        };

    for (u64 converge = 0; converge <= time; ++converge) {
        if (lambda(converge, start)) break;
    }
    for (u64 converge = time; converge >= 0; --converge) {
        if (lambda(converge, end)) break;
    }

    return end + 1 - start;
}

static auto parseLine(std::string const &line, std::vector<u64> &vec) -> void {
    std::stringstream ss;
    ss << line.substr(line.find_first_of(':', 0) + 1);

    u64 number;
    while (ss >> number)
        vec.push_back(number);
}
