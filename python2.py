python3 -c "
coeffs = [287, 1571, 5375, 9151, 9151, 5375, 1571, 287]
max_out = sum(c * 32767 for c in coeffs)
print('Max output:', max_out)
print('Bits needed:', max_out.bit_length())
"
