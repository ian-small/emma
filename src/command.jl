
module EmmaCommand

using ArgMacros, Emma

args = @dictarguments begin
    @helpusage "Emma/src/command.jl [options] <FASTA_file>"
    @helpdescription """
        Note: Use consistant inputs/outputs. If you wish
        to annotate a directory of fasta files, ensure that
        the output parameters are also directories.
        """
    @argumentoptional String GFF_out "--gff" 
    @arghelp "file/dir for gff output"
    @argumentoptional String GB_out "--gb"
    @arghelp "file/dir for gb output"
    @argumentoptional String FA_out "--fa"
    @arghelp "file/dir for fasta output. Use this argument if you wish annotations to begin with tRNA-Phe"
    @argumentoptional String SVG_out "--svg"
    @arghelp "file/dir for svg output"
    @positionalrequired String FASTA_file
    @arghelp "file/dir for fasta input"
end
println(ARGS)
filtered_args = filter(pair -> ~isnothing(pair.second), args)
all_dirs = all(isdir, values(filtered_args))
all_files = !any(isdir, values(filtered_args))
if all_dirs
    fafiles = filter!(x->endswith(x,".fa") || endswith(x,".fasta"), readdir(args[:FASTA_file], join=true))
    for fasta in fafiles
        accession = first(split(basename(fasta),"."))
        outfile_gff = haskey(filtered_args, :GFF_out) ? joinpath(args[:GFF_out], accession * ".gff") : nothing
        outfile_gb = haskey(filtered_args, :GB_out) ? joinpath(args[:GB_out], accession * ".gb") : nothing
        outfile_fa = haskey(filtered_args, :FA_out) ? joinpath(args[:FA_out], accession * ".fa") : nothing
        outfile_svg = haskey(filtered_args, :SVG_out) ? joinpath(args[:SVG_out], accession * ".svg") : nothing
        main(fasta; outfile_gff=outfile_gff, outfile_gb=outfile_gb, outfile_fa=outfile_fa, outfile_svg=outfile_svg)
    end
elseif all_files
    emma(args[:FASTA_file]; outfile_gff = args[:GFF_out], outfile_gb = args[:GB_out], outfile_fa = args[:FA_out], outfile_svg = args[:SVG_out])
else
    throw("Inputs must be consistant; all directories or all files")
end

end