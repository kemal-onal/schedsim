EXEC=schedsim
SRC_DIR=src
SRCS=$(SRC_DIR)/schedsim.s $(SRC_DIR)/parser.s $(SRC_DIR)/data.s $(SRC_DIR)/fcfs.s $(SRC_DIR)/sjf.s $(SRC_DIR)/srtf.s $(SRC_DIR)/pf.s $(SRC_DIR)/rr.s
OBJS=$(SRCS:.s=.o)
TEST_DIR=test-cases
OUTPUT_DIR=my-outputs

all: $(EXEC)

$(EXEC): $(OBJS)
	ld -o $(EXEC) $(OBJS)

$(SRC_DIR)/%.o: $(SRC_DIR)/%.s
	as -o $@ $<

testcases: $(EXEC)
	@echo "Running test cases..."
	@mkdir -p $(OUTPUT_DIR)
	@for infile in $(TEST_DIR)/input_*.txt; do \
		base=$$(basename $$infile); \
		outfile=$$(echo $$base | sed 's/input_/output_/'); \
		echo "  > $$infile -> $(OUTPUT_DIR)/$$outfile"; \
		./$(EXEC) < $$infile > $(OUTPUT_DIR)/$$outfile; \
	done

grade: testcases
	python3 test/grader.py ./$(EXEC) $(TEST_DIR)

clean:
	rm -f $(EXEC) $(OBJS)
	rm -rf $(OUTPUT_DIR)
