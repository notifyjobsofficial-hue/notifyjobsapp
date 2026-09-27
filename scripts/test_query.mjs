import https from 'https';

const apiKey = 'AIzaSyA4HKLllBma7SsHBeumtit83h9L9Z5eOzE';
const projectId = 'notify-jobs-753b8';

function runPost(path, body) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(body);
    const req = https.request({
      hostname: 'firestore.googleapis.com',
      path: `${path}?key=${apiKey}`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data),
      },
    }, (res) => {
      let resData = '';
      res.on('data', chunk => resData += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(resData));
        } catch (e) {
          resolve(resData);
        }
      });
    });
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

async function main() {
  const queryBody = {
    structuredQuery: {
      from: [{ collectionId: 'content' }],
      where: {
        compositeFilter: {
          op: 'AND',
          filters: [
            {
              fieldFilter: {
                field: { fieldPath: 'isPublished' },
                op: 'EQUAL',
                value: { booleanValue: true },
              },
            },
            {
              fieldFilter: {
                field: { fieldPath: 'status' },
                op: 'EQUAL',
                value: { stringValue: 'published' },
              },
            },
          ],
        },
      },
      limit: 100,
    },
  };

  const results = await runPost(`/v1/projects/${projectId}/databases/(default)/documents:runQuery`, queryBody);
  if (!Array.isArray(results)) {
    console.log('Error/Non-array response:', results);
    return;
  }

  const validDocs = results.filter(r => r.document);
  console.log(`\n======================================================`);
  console.log(`TOTAL PUBLISHED CONTENT DOCUMENTS FOUND: ${validDocs.length}`);
  console.log(`======================================================`);

  validDocs.forEach((r, idx) => {
    const doc = r.document;
    const id = doc.name.split('/').pop();
    const f = doc.fields || {};

    const title = f.title?.stringValue || '(no title)';
    const contentType = f.contentType?.stringValue || '(no contentType)';
    const status = f.status?.stringValue || '(no status)';
    const isPublished = f.isPublished?.booleanValue;
    const publishedAt = f.publishedAt?.stringValue || f.publishedAt?.timestampValue || '(none)';
    const showOnHome = f.showOnHome?.booleanValue;
    const showInLiveUpdates = f.showInLiveUpdates?.booleanValue;
    const categoryIds = f.categoryIds?.arrayValue?.values?.map(v => v.stringValue) || [];
    const location = f.location?.stringValue || '(no location)';
    const vacancies = f.vacancies?.stringValue || f.vacancies?.integerValue || '(none)';

    console.log(`\n[${idx + 1}] ID: ${id}`);
    console.log(`    Title:             ${title}`);
    console.log(`    ContentType:       ${contentType}`);
    console.log(`    Status:            ${status}`);
    console.log(`    isPublished:       ${isPublished}`);
    console.log(`    PublishedAt:       ${publishedAt}`);
    console.log(`    showOnHome:        ${showOnHome}`);
    console.log(`    showInLiveUpdates: ${showInLiveUpdates}`);
    console.log(`    categoryIds:       ${JSON.stringify(categoryIds)}`);
    console.log(`    Location:          ${location}`);
    console.log(`    Vacancies:         ${vacancies}`);
    console.log(`    All fields:        ${Object.keys(f).join(', ')}`);
  });
}

main().catch(console.error);
