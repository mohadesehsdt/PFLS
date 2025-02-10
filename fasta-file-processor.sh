

# Extract sequences (ignoring lines starting with '>')
sequences=$(awk '!/^>/ {print}' "$1")

# Count the number of sequences
num_sequences=$(grep -c '^>' "$1")

#total length
total_length=$(awk '/^>/ {next} {sum += length} END {print sum}' "$1")


# Get sequence lengths
lengths=$(awk '/^>/ {next} {print length}' "$1")
longest=$(echo "$lengths" | sort -nr | head -n1)
shortest=$(echo "$lengths" | sort -n | head -n1)
average_length=$((total_length / num_sequences))
gc_count=$(echo "$sequences" | grep -o '[GC]' | wc -l)
gc_content=$(echo "$gc_count * 100 / $total_length" | bc -l)



# Print the resultsc
echo "FASTA File Statistics:"
echo "----------------------"
echo "Number of sequences: $num_sequences"
echo "Total length of sequences: $total_length"
echo "Length of the longest sequence: $longest"
echo "Length of the shortest sequence: $shortest"
echo "Average sequence length: $average_length"
echo "GC Content (%): $gc_content"