#include <iostream>
#include <vector>
#include <string>
#include <sstream>

struct FT {
    unsigned long toStart;
    unsigned long fromStart;
    unsigned long range;

    FT(std::string const &line) {
        unsigned long to, from, r;

        // yes, sscanf, who cares
        sscanf(line.c_str(), "%ld %ld %ld", &to, &from, &r);

        toStart = to;
        fromStart = from;
        range = r;

    }

    bool isIn(unsigned long from) {
        return (from >= fromStart)
            and (from < fromStart + range);
    }
    unsigned long getVal(unsigned long from) {
        return from + toStart - fromStart;
    }
};

auto main(void) -> int {
    std::vector<FT> sts;
    std::vector<FT> stf;
    std::vector<FT> ftw;
    std::vector<FT> wtl;
    std::vector<FT> ltt;
    std::vector<FT> tth;
    std::vector<FT> htl;

    FT f{ "50 98 2" };
    std::cout << f.getVal(98) << std::endl;

    return 0;
}
