<?xml version="1.0" encoding="UTF-8"?>
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" version="1.0">
<param name="chunk.quietly">1</param>
<!-- One file per chapter, not per section -->
<param name="chunk.section.depth">0</param>
<!-- Label chapters and sections like DebianDoc -->
<param name="chapter.autolabel">1</param>
<param name="section.autolabel">1</param>
<param name="section.label.includes.component.label">1</param>
<!-- Where auto-generated IDs are needed, generate them consistently,
     for reproducible builds -->
<param name="generate.consistent.ids">1</param>
<!-- Put each <term> on a separate line, with no other separator -->
<param name="variablelist.term.break.after">1</param>
<param name="variablelist.term.separator"/>
</stylesheet>
