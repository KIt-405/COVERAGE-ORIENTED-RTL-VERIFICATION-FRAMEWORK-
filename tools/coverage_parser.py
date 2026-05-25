import re
import json

def parse_simulation_report(log_path):
    """
    Parses structural verification logs to extract functional target summaries.
    """
    mismatch_counter = 0
    assertion_failures = 0
    coverage_score = "0.0%"

    # Regex compilation matches to evaluate transcript files
    mismatch_regex = re.compile(r"\[MISMATCH ERROR\]")
    assertion_regex = re.compile(r"\[ASSERTION ERROR\]")
    coverage_regex = re.compile(r"Total Functional Coverage Metric Achieved:\s+([0-9.]+\%)")

    with open(log_path, 'r') as file:
        for line in file:
            if mismatch_regex.search(line):
                mismatch_counter += 1
            if assertion_regex.search(line):
                assertion_failures += 1
            match = coverage_regex.search(line)
            if match:
                coverage_score = match.group(1)

    # Compile findings into a structured dictionary report
    summary_report = {
        "Data_Mismatches_Detected": mismatch_counter,
        "SVA_Assertion_Violations": assertion_failures,
        "Final_Functional_Coverage_Achieved": coverage_score,
        "Status": "PASSED" if (mismatch_counter == 0 and assertion_failures == 0) else "FAILED"
    }

    # Print out a clear, structured JSON visualization to console
    print(json.dumps(summary_report, indent=4))

if __name__ == "__main__":
    # Assumes simulation logged directly into simulation_transcript.log file
    parse_simulation_report("simulation_transcript.log")
