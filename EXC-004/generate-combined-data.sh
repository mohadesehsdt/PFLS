
rm -rf COMBINED-DATA
mkdir -p COMBINED-DATA

 # Detect OS type
if [[ "$OSTYPE" == "darwin"* ]]
then
    SED_COMMAND="sed -i ''"
else
    SED_COMMAND="sed -i"
fi

for direction in $(ls -d RAW-DATA/DNA*)
do
    culturen=$(basename $direction)
    new_culturen=$(grep $culturen RAW-DATA/sample-translation.txt | awk '{print $2}')

    MAG_counter=1
    BIN_counter=1

    cp $direction/checkm.txt COMBINED-DATA/$new_culturen-CHECKM.txt
    cp $direction/gtdb.gtdbtk.tax COMBINED-DATA/$new_culturen-GTDB-TAX.txt

    for fasta_file in $direction/bins/*.fasta
    do
        bin_name=$(basename $fasta_file .fasta)

        completion=$(grep "$bin_name " $direction/checkm.txt | awk '{print $13}')
        contamination=$(grep "$bin_name " $direction/checkm.txt | awk '{print $14}')
        
        if [[ $bin_name == bin-unbinned ]]
        then
            new_name="${new_culturen}_UNBINNED.fa"
            echo "$new_culturen unbinned contigs ($new_name) ..."
        elif (( $(echo "$completion >= 50" | bc -l) && $(echo "$contamination < 5" | bc -l) ))
        then
            new_name=$(printf "${new_culturen}_MAG_%03d.fa" $MAG_counter)
            echo "$new_culturen MAG $bin_name ($new_name) (comp/cont $completion/$contamination) ..."
            MAG_counter=$(("$MAG_counter + 1"))
        else
            new_name=$(printf "${new_culturen}_BIN_%03d.fa" $BIN_counter)
            echo "$new_culturen BIN $bin_name ($new_name) (comp/cont $completion/$contamination) ..."
            BIN_counter=$(($BIN_counter + 1))
        fi
        
        $SED_COMMAND "s/ms.*${bin_name}/$(basename $new_name .fa)/g" COMBINED-DATA/$new_culturen-CHECKM.txt
        $SED_COMMAND "s/ms.*${bin_name}/$(basename $new_name .fa)/g" COMBINED-DATA/$new_culturen-GTDB-TAX.txt
        
        cp "$fasta_file" "COMBINED-DATA/$new_name"
        awk -v prefix="$new_culturen" '/^>/ {print ">" prefix "_" ++count; next} {print}' "$fasta_file" > "COMBINED-DATA/$new_name"
    done
done 
echo "Processing complete. All files are stored in COMBINED-DATA."