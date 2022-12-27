// const {
//     BlobSASPermissions,
//     SharedKeyCredential,
//     generateBlobSASQueryParameters,
//     StorageSharedKeyCredential
//   } = require("@azure/storage-blob");
// let blobUrl = 
// ``;

// const sasOptions = {
//     containerName: "",
//     blobName: "",
//     expiresOn: new Date(new Date().valueOf() + ),
//     permissions: BlobSASPermissions.parse('r')
// };

// const sharedKeyCredential = new StorageSharedKeyCredential(
//     "", 
//     ""
// );

// const sasToken = generateBlobSASQueryParameters(sasOptions, sharedKeyCredential).toString();
// blobUrl += sasToken;
// console.log(blobUrl)
