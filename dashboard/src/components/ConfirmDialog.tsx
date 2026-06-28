import { useState, useEffect } from 'react';
import { CheckCircle, XCircle, AlertTriangle, Trash2 } from 'lucide-react';

interface ConfirmDialogProps {
  open: boolean;
  mode: 'approve' | 'reject' | 'delete';
  title?: string;
  message?: string;
  confirmLabel?: string;
  onCancel: () => void;
  onConfirm: (reason?: string) => void;
}

export default function ConfirmDialog({
  open,
  mode,
  title,
  message,
  confirmLabel,
  onCancel,
  onConfirm,
}: ConfirmDialogProps) {
  const [reason, setReason] = useState('');

  // Reset the reason whenever the dialog is (re)opened.
  useEffect(() => {
    if (open) setReason('');
  }, [open, mode]);

  if (!open) return null;

  const isReject = mode === 'reject';
  const isDelete = mode === 'delete';

  const defaultTitle = isDelete
    ? 'Delete Record'
    : isReject
    ? 'Reject Request'
    : 'Approve Request';
  const defaultMessage = isDelete
    ? 'Are you sure you want to delete this record? This action is permanent and cannot be undone.'
    : isReject
    ? 'Are you sure you want to reject this request? Please provide a reason below.'
    : 'Are you sure you want to approve this request? This will make it visible to donors.';
  const defaultConfirmLabel = isDelete ? 'Delete' : isReject ? 'Reject' : 'Approve';

  const handleConfirm = () => {
    if (isReject) {
      const trimmed = reason.trim();
      if (!trimmed) return;
      onConfirm(trimmed);
    } else {
      onConfirm();
    }
  };

  return (
    <div className="fixed inset-0 z-[60] overflow-y-auto">
      <div className="flex items-center justify-center min-h-screen px-4">
        <div
          className="fixed inset-0 bg-neutral-900 bg-opacity-50 transition-opacity"
          onClick={onCancel}
        ></div>
        <div className="relative bg-white rounded-xl shadow-strong max-w-md w-full p-6">
          <div className="flex items-start gap-4">
            <div
              className={`flex-shrink-0 p-3 rounded-full ${
                isReject || isDelete ? 'bg-red-100' : 'bg-green-100'
              }`}
            >
              {isDelete ? (
                <Trash2 className="w-6 h-6 text-red-600" />
              ) : isReject ? (
                <AlertTriangle className="w-6 h-6 text-red-600" />
              ) : (
                <CheckCircle className="w-6 h-6 text-green-600" />
              )}
            </div>
            <div className="flex-1">
              <h3 className="text-lg font-bold text-neutral-900">
                {title || defaultTitle}
              </h3>
              <p className="text-sm text-neutral-600 mt-1">
                {message || defaultMessage}
              </p>
            </div>
          </div>

          {isReject && (
            <div className="mt-4">
              <label className="text-sm font-medium text-neutral-600">
                Rejection Reason
              </label>
              <textarea
                value={reason}
                onChange={(e) => setReason(e.target.value)}
                rows={3}
                placeholder="Enter a reason for rejection..."
                className="input-field w-full mt-1 resize-none"
                autoFocus
              />
            </div>
          )}

          <div className="flex gap-3 mt-6">
            <button
              onClick={onCancel}
              className="flex-1 btn-secondary"
            >
              Cancel
            </button>
            <button
              onClick={handleConfirm}
              disabled={isReject && !reason.trim()}
              className={`flex-1 inline-flex items-center justify-center px-4 py-2.5 rounded-lg font-medium text-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed ${
                isReject || isDelete
                  ? 'bg-red-600 hover:bg-red-700'
                  : 'bg-green-600 hover:bg-green-700'
              }`}
            >
              {isDelete ? (
                <Trash2 className="w-4 h-4 mr-2" />
              ) : isReject ? (
                <XCircle className="w-4 h-4 mr-2" />
              ) : (
                <CheckCircle className="w-4 h-4 mr-2" />
              )}
              {confirmLabel || defaultConfirmLabel}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
