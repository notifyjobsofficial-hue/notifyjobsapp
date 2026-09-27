import https from 'https';

const url = 'https://firestore.googleapis.com/v1/projects/notify-jobs-753b8/databases/(default)/documents/content?pageSize=50&key=AIzaSyA4HKLllBma7SsHBeumtit83h9L9Z5eOzE';

https.get(url, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    try {
      const json = JSON.parse(data);
      if (json.documents) {
        console.log('Total documents returned:', json.documents.length);
        json.documents.forEach((doc, i) => {
          const id = doc.name.split('/').pop();
          const f = doc.fields || {};
          console.log(`\n=== Doc ${i + 1}: ${id} ===`);
          console.log('title:', f.title ? (f.title.stringValue || JSON.stringify(f.title)) : '(no title)');
          console.log('contentType:', f.contentType ? (f.contentType.stringValue || JSON.stringify(f.contentType)) : '(no contentType)');
          console.log('status:', f.status ? (f.status.stringValue || JSON.stringify(f.status)) : '(no status)');
          console.log('isPublished:', f.isPublished ? (f.isPublished.booleanValue !== undefined ? f.isPublished.booleanValue : JSON.stringify(f.isPublished)) : 'MISSING');
          console.log('publishedAt:', f.publishedAt ? (f.publishedAt.stringValue || f.publishedAt.timestampValue || JSON.stringify(f.publishedAt)) : '(no publishedAt)');
          console.log('showOnHome:', f.showOnHome ? (f.showOnHome.booleanValue !== undefined ? f.showOnHome.booleanValue : JSON.stringify(f.showOnHome)) : 'MISSING');
          console.log('showInLiveUpdates:', f.showInLiveUpdates ? (f.showInLiveUpdates.booleanValue !== undefined ? f.showInLiveUpdates.booleanValue : JSON.stringify(f.showInLiveUpdates)) : 'MISSING');
          const catIds = f.categoryIds?.arrayValue?.values?.map(v => v.stringValue) || [];
          console.log('categoryIds:', catIds);
          console.log('all field names:', Object.keys(f));
        });
      } else {
        console.log('Response (no documents):', JSON.stringify(json, null, 2));
      }
    } catch(e) {
      console.error(e, data);
    }
  });
}).on('error', err => console.error(err));
