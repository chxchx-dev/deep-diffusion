export default function HelpTip({ text }: { text: string }) {
    return <span className="help-tip" title={text} tabIndex={0} role="note" aria-label={text}>?</span>;
}
