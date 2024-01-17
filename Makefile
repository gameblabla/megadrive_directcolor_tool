CC ?= gcc
CFLAGS=-Wall -g
LDFLAGS=-lpng

# The name of your output program
TARGET=pngtodirectcolor.elf

# List of your source files
SOURCES=pngtodirectcolor.c

# List of your object files (derived from SOURCES)
OBJECTS=$(SOURCES:.c=.o)

# Default target
all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $<

# Clean up
clean:
	rm -f $(TARGET) $(OBJECTS)
