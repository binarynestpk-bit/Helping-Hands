interface CsvColumn {
  key: string;
  label: string;
}

function escapeCell(value: any): string {
  if (value === null || value === undefined) return '';
  const str = String(value);
  // Quote the cell if it contains a comma, quote, or newline; escape quotes by doubling.
  if (/[",\n\r]/.test(str)) {
    return `"${str.replace(/"/g, '""')}"`;
  }
  return str;
}

/**
 * Build a CSV from `rows` and trigger a browser download.
 * If `columns` is provided, only those keys are exported (in order) and their
 * labels are used as the header row. Otherwise keys of the first row are used.
 * Does nothing when `rows` is empty.
 */
export function exportToCsv(
  filename: string,
  rows: any[],
  columns?: CsvColumn[]
): void {
  if (!rows || rows.length === 0) {
    if (typeof window !== 'undefined') {
      window.alert('No data to export');
    }
    return;
  }

  const cols: CsvColumn[] =
    columns && columns.length > 0
      ? columns
      : Object.keys(rows[0]).map((key) => ({ key, label: key }));

  const header = cols.map((c) => escapeCell(c.label)).join(',');
  const body = rows
    .map((row) => cols.map((c) => escapeCell(row[c.key])).join(','))
    .join('\r\n');

  const csv = `${header}\r\n${body}`;

  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.setAttribute('download', filename);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
}

/** Returns today's date as YYYY-MM-DD for filenames. */
export function csvDateStamp(): string {
  const d = new Date();
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${d.getFullYear()}-${month}-${day}`;
}
