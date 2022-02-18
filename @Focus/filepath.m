function out = filepath(this, tag)

arguments
    this
    tag char
end

out = [this.Dir.Files tag '.mat'];