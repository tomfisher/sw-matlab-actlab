function filename = wav_filename(Repository, Part)
% function filename = wav_filename(Repository, Part)
%
% generate wav file name

RepEntry = Repository.RepEntries;

filename = [Repository.Path filesep RepEntry(Part).Dir filesep RepEntry(Part).WAVFile];