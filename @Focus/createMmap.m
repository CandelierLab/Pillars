function createMmap(this)

% --- Initialize mmap file

if this.verbose
    fprintf('--- Creating memory map file\n');
    fprintf('  * Initialization ...');
    tic
end

fid = fopen(this.File.mmap, 'w');
for i = 1:this.T
    fwrite(fid, zeros(this.H, this.W), 'double');
end
fclose(fid);

if this.verbose
    fprintf(' %.02f sec\n', toc);
end

% --- Define mmap object

this.mmap = memmapfile(this.File.mmap, 'Format', {'double' [this.H this.W] 'frame' }, ...
    'Repeat', this.T, 'Writable', true);

% --- Populating mmap file

if this.verbose
    fprintf('  * Populating .');
    tic
end

i = 1;
VR = VideoReader(this.File.video);

while hasFrame(VR)
    tmp = readFrame(VR);
    
    % Smooth (for jpeg compression artifact)
    GL = imgaussfilt(double(tmp(:,:,1)), 1);

    % Flatten background intensities
    ML = medfilt2(tmp(:,:,1), [1 1]*100, 'symmetric');
        
    this.mmap.Data(i).frame = GL - imgaussfilt(double(ML), 5);
    i = i+1;
    
    if this.verbose && ~mod(i,100)
        fprintf('.'); 
    end
end

if this.verbose
    fprintf(' %.02f sec\n', toc);
end
