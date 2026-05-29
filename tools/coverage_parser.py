import re
import json
import sys
import os

def parse_simulation_report(log_path):
    mismatch_counter = 0
    assertion_failures = 0
    coverage_score = "N/A" 

    mismatch_regex = re.compile(r"\[MISMATCH ERROR\]")
    assertion_regex = re.compile(r"\[ASSERTION ERROR\]")
    coverage_regex = re.compile(r"Total Functional Coverage Metric Achieved:\s+([0-9.]+\%)")

    if not os.path.exists(log_path):
        print(f"Error: Log file '{log_path}' not found. Did the simulation run?")
        sys.exit(1)

    try:
        with open(log_path, 'r') as file:
            for line in file:
                if mismatch_regex.search(line):
                    mismatch_counter += 1
                if assertion_regex.search(line):
                    assertion_failures += 1
                
                match = coverage_regex.search(line)
                if match:
                    coverage_score = match.group(1)
    except Exception as e:
        print(f"Error reading file '{log_path}': {e}")
        sys.exit(1)

    summary_report = {
        "Data_Mismatches_Detected": mismatch_counter,
        "SVA_Assertion_Violations": assertion_failures,
        "Final_Functional_Coverage_Achieved": coverage_score,
        "Status": "PASSED" if (mismatch_counter == 0 and assertion_failures == 0) else "FAILED"
    }

    print(json.dumps(summary_report, indent=4))

if __name__ == "__main__":
    target_log = sys.argv[1] if len(sys.argv) > 1 else "simulation_transcript.log"
    parse_simulation_report(target_log)
