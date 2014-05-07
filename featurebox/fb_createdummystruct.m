function DataStruct = fb_createdummystruct

DataStruct.Data = rand(10*44100,1);
DataStruct.FeatureString = {'IEAR_lpc_MEAN', 'IEAR_lpcnative_MEAN', 'IEAR_lpcc_MEAN'};
DataStruct.SampleRate = 44100;
DataStruct.DTable = {'IEAR'};
DataStruct.swstep = 512;
DataStruct.swsize = 512;