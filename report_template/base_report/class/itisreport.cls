%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% itisreport.cls
%
% LaTeX class template for ITIS Foundation reports
% Calibration Laboratory of Schmid & Partner Engineering AG
% Zeughausstrasse 43, 8004 Zurich, Switzerland
% Accreditation No.: SCS 0108
%
% code by E. A. Farina - TeX.Academy elio.farina@gmail.com
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\NeedsTeXFormat{LaTeX2e}
\RequirePackage{etoolbox}
\IfFileExists{./class/itisreport.cls}%
    {\ProvidesClass{./class/itisreport}}%
    {\ProvidesClass{itisreport}}%
    [2021/10/14 v0.2 LaTeX class for ITIS Foundation reports]%
    % Class path
    \newcommand{\PATHCLASS}{}
    \IfFileExists{itisreport.cls}{\renewcommand{\PATHCLASS}{}}{}
    \IfFileExists{./class/itisreport.cls}{\renewcommand{\PATHCLASS}{./class}}{}
    \IfFileExists{../class/itisreport.cls}{\renewcommand{\PATHCLASS}{../class}}{}
    \IfFileExists{../../class/itisreport.cls}{\renewcommand{\PATHCLASS}{../../class}}{}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% article.cls 2020/04/10 v1.4m
    \newbool{cover}
    \newbool{titlepage}
    \DeclareOption{cover}{\booltrue{cover}}
    \DeclareOption{nocover}{\boolfalse{cover}}
    \newcommand\@ptsize{}
    \newif\if@restonecol
    \newif\if@titlepage
    \@titlepagefalse
    \if@compatibility\else
      \DeclareOption{a4paper}
         {\setlength\paperheight {297mm}%
          \setlength\paperwidth  {210mm}}
    \fi
    \if@compatibility
      \renewcommand\@ptsize{0}
    \else
      \DeclareOption{10pt}{\renewcommand\@ptsize{0}}
    \fi
    \DeclareOption{11pt}{\renewcommand\@ptsize{1}}
    \DeclareOption{12pt}{\renewcommand\@ptsize{2}}
    \if@compatibility\else
      \DeclareOption{oneside}{\@twosidefalse \@mparswitchfalse}
    \fi
    \DeclareOption{twoside}{\@twosidetrue  \@mparswitchtrue}
    \DeclareOption{draft}{\setlength\overfullrule{5pt}}
    \if@compatibility\else
      \DeclareOption{final}{\setlength\overfullrule{0pt}}
    \fi
    \DeclareOption{titlepage}{\booltrue{titlepage}\@titlepagetrue}
    \if@compatibility\else
      \DeclareOption{notitlepage}{\boolfalse{titlepage}\@titlepagefalse}
    \fi
    \if@compatibility\else
      \DeclareOption{onecolumn}{\@twocolumnfalse}
    \fi
    \DeclareOption{twocolumn}{\@twocolumntrue}
    \DeclareOption{leqno}{\input{leqno.clo}}
    \DeclareOption{fleqn}{\input{fleqn.clo}}
    \DeclareOption{openbib}{%
      \AtEndOfPackage{%
        \renewcommand\@openbib@code{%
          \advance\leftmargin\bibindent
          \itemindent -\bibindent
          \listparindent \itemindent
          \parsep \z@
          }%
        \renewcommand\newblock{\par}}%
    }
    \ExecuteOptions{a4paper,11pt,twoside,onecolumn,titlepage,final,cover}
    \ProcessOptions
    \input{size1\@ptsize.clo}
    \setlength\lineskip{1\p@}
    \setlength\normallineskip{1\p@}
    \renewcommand\baselinestretch{}
    \setlength\parskip{0\p@ \@plus \p@}
    \@lowpenalty   51
    \@medpenalty  151
    \@highpenalty 301
    \setcounter{topnumber}{2}
    \renewcommand\topfraction{.7}
    \setcounter{bottomnumber}{1}
    \renewcommand\bottomfraction{.3}
    \setcounter{totalnumber}{3}
    \renewcommand\textfraction{.2}
    \renewcommand\floatpagefraction{.5}
    \setcounter{dbltopnumber}{2}
    \renewcommand\dbltopfraction{.7}
    \renewcommand\dblfloatpagefraction{.5}
    \if@twoside
      \def\ps@headings{%
          \let\@oddfoot\@empty\let\@evenfoot\@empty
          \def\@evenhead{\thepage\hfil\slshape\leftmark}%
          \def\@oddhead{{\slshape\rightmark}\hfil\thepage}%
          \let\@mkboth\markboth
        \def\sectionmark##1{%
          \markboth {\MakeUppercase{%
            \ifnum \c@secnumdepth >\z@
              \thesection\quad
            \fi
            ##1}}{}}%
        \def\subsectionmark##1{%
          \markright {%
            \ifnum \c@secnumdepth >\@ne
              \thesubsection\quad
            \fi
            ##1}}}
    \else
      \def\ps@headings{%
        \let\@oddfoot\@empty
        \def\@oddhead{{\slshape\rightmark}\hfil\thepage}%
        \let\@mkboth\markboth
        \def\sectionmark##1{%
          \markright {\MakeUppercase{%
            \ifnum \c@secnumdepth >\m@ne
              \thesection\quad
            \fi
            ##1}}}}
    \fi
    \def\ps@myheadings{%
        \let\@oddfoot\@empty\let\@evenfoot\@empty
        \def\@evenhead{\thepage\hfil\slshape\leftmark}%
        \def\@oddhead{{\slshape\rightmark}\hfil\thepage}%
        \let\@mkboth\@gobbletwo
        \let\sectionmark\@gobble
        \let\subsectionmark\@gobble
        }
    \if@titlepage
      \newcommand\maketitle{\begin{titlepage}%
      \let\footnotesize\small
      \let\footnoterule\relax
      \let \footnote \thanks
      \null\vfil
      \vskip 60\p@
      \begin{center}%
        {\LARGE \@title \par}%
        \vskip 3em%
        {\large
         \lineskip .75em%
          \begin{tabular}[t]{c}%
            \@author
          \end{tabular}\par}%
          \vskip 1.5em%
        {\large \@date \par}%       % Set date in \large size.
      \end{center}\par
      \@thanks
      \vfil\null
      \end{titlepage}%
      \setcounter{footnote}{0}%
      \global\let\thanks\relax
      \global\let\maketitle\relax
      \global\let\@thanks\@empty
      \global\let\@author\@empty
      \global\let\@date\@empty
      \global\let\@title\@empty
      \global\let\title\relax
      \global\let\author\relax
      \global\let\date\relax
      \global\let\and\relax
      }
    \else
      \newcommand\maketitle{\par
        \begingroup
          \renewcommand\thefootnote{\@fnsymbol\c@footnote}%
          \def\@makefnmark{\rlap{\@textsuperscript{\normalfont\@thefnmark}}}%
          \long\def\@makefntext##1{\parindent 1em\noindent
                  \hb@xt@1.8em{%
                    \hss\@textsuperscript{\normalfont\@thefnmark}}##1}%
          \if@twocolumn
            \ifnum \col@number=\@ne
              \@maketitle
            \else
              \twocolumn[\@maketitle]%
            \fi
          \else
          \newpage
            \global\@topnum\z@   % Prevents figures from going at top of page.
            \@maketitle
          \fi
          \thispagestyle{plain}\@thanks
        \endgroup
        \setcounter{footnote}{0}%
        \global\let\thanks\relax
        \global\let\maketitle\relax
        \global\let\@maketitle\relax
        \global\let\@thanks\@empty
        \global\let\@author\@empty
        \global\let\@date\@empty
        \global\let\@title\@empty
        \global\let\title\relax
        \global\let\author\relax
        \global\let\date\relax
        \global\let\and\relax
      }
    \def\@maketitle{%
      \newpage
      \null
      \vskip 2em%
      \begin{center}%
      \let \footnote \thanks
        {\LARGE \@title \par}%
        \vskip 1.5em%
        {\large
          \lineskip .5em%
          \begin{tabular}[t]{c}%
            \@author
          \end{tabular}\par}%
        \vskip 1em%
        {\large \@date}%
      \end{center}%
      \par
      \vskip 1.5em}
    \fi
    \setcounter{secnumdepth}{3}
    \newcounter {part}
    \newcounter {section}
    \newcounter {subsection}[section]
    \newcounter {subsubsection}[subsection]
    \newcounter {paragraph}[subsubsection]
    \newcounter {subparagraph}[paragraph]
    \renewcommand \thepart {\@Roman\c@part}
    \renewcommand \thesection {\@arabic\c@section}
    \renewcommand\thesubsection   {\thesection.\@arabic\c@subsection}
    \renewcommand\thesubsubsection{\thesubsection.\@arabic\c@subsubsection}
    \renewcommand\theparagraph    {\thesubsubsection.\@arabic\c@paragraph}
    \renewcommand\thesubparagraph {\theparagraph.\@arabic\c@subparagraph}
    \newcommand\part{%
       \if@noskipsec \leavevmode \fi
       \par
       \addvspace{4ex}%
       \@afterindentfalse
       \secdef\@part\@spart}

    \def\@part[#1]#2{%
        \ifnum \c@secnumdepth >\m@ne
          \refstepcounter{part}%
          \addcontentsline{toc}{part}{\thepart\hspace{1em}#1}%
        \else
          \addcontentsline{toc}{part}{#1}%
        \fi
        {\parindent \z@ \raggedright
         \interlinepenalty \@M
         \normalfont
         \ifnum \c@secnumdepth >\m@ne
           \Large\bfseries \partname\nobreakspace\thepart
           \par\nobreak
         \fi
         \huge \bfseries #2%
         \markboth{}{}\par}%
        \nobreak
        \vskip 3ex
        \@afterheading}
    \def\@spart#1{%
        {\parindent \z@ \raggedright
         \interlinepenalty \@M
         \normalfont
         \huge \bfseries #1\par}%
         \nobreak
         \vskip 3ex
         \@afterheading}
    \newcommand\section{\@startsection {section}{1}{\z@}%
                                       {-3.5ex \@plus -1ex \@minus -.2ex}%
                                       {2.3ex \@plus.2ex}%
                                       {\normalfont\Large\bfseries}}
    \newcommand\subsection{\@startsection{subsection}{2}{\z@}%
                                         {-3.25ex\@plus -1ex \@minus -.2ex}%
                                         {1.5ex \@plus .2ex}%
                                         {\normalfont\large\bfseries}}
    \newcommand\subsubsection{\@startsection{subsubsection}{3}{\z@}%
                                         {-3.25ex\@plus -1ex \@minus -.2ex}%
                                         {1.5ex \@plus .2ex}%
                                         {\normalfont\normalsize\bfseries}}
    \newcommand\paragraph{\@startsection{paragraph}{4}{\z@}%
                                        {3.25ex \@plus1ex \@minus.2ex}%
                                        {-1em}%
                                        {\normalfont\normalsize\bfseries}}
    \newcommand\subparagraph{\@startsection{subparagraph}{5}{\parindent}%
                                           {3.25ex \@plus1ex \@minus .2ex}%
                                           {-1em}%
                                          {\normalfont\normalsize\bfseries}}
    \if@twocolumn
      \setlength\leftmargini  {2em}
    \else
      \setlength\leftmargini  {2.5em}
    \fi
    \leftmargin  \leftmargini
    \setlength\leftmarginii  {2.2em}
    \setlength\leftmarginiii {1.87em}
    \setlength\leftmarginiv  {1.7em}
    \if@twocolumn
      \setlength\leftmarginv  {.5em}
      \setlength\leftmarginvi {.5em}
    \else
      \setlength\leftmarginv  {1em}
      \setlength\leftmarginvi {1em}
    \fi
    \setlength  \labelsep  {.5em}
    \setlength  \labelwidth{\leftmargini}
    \addtolength\labelwidth{-\labelsep}
    \@beginparpenalty -\@lowpenalty
    \@endparpenalty   -\@lowpenalty
    \@itempenalty     -\@lowpenalty
    \renewcommand\theenumi{\@arabic\c@enumi}
    \renewcommand\theenumii{\@alph\c@enumii}
    \renewcommand\theenumiii{\@roman\c@enumiii}
    \renewcommand\theenumiv{\@Alph\c@enumiv}
    \newcommand\labelenumi{\theenumi.}
    \newcommand\labelenumii{(\theenumii)}
    \newcommand\labelenumiii{\theenumiii.}
    \newcommand\labelenumiv{\theenumiv.}
    \renewcommand\p@enumii{\theenumi}
    \renewcommand\p@enumiii{\theenumi(\theenumii)}
    \renewcommand\p@enumiv{\p@enumiii\theenumiii}
    \newcommand\labelitemi  {\labelitemfont \textbullet}
    \newcommand\labelitemii {\labelitemfont \bfseries \textendash}
    \newcommand\labelitemiii{\labelitemfont \textasteriskcentered}
    \newcommand\labelitemiv{ \labelitemfont \textperiodcentered}
    \newcommand\labelitemfont{\normalfont}
    \newenvironment{description}
                   {\list{}{\labelwidth\z@ \itemindent-\leftmargin
                            \let\makelabel\descriptionlabel}}
                   {\endlist}
    \newcommand*\descriptionlabel[1]{\hspace\labelsep
                                    \normalfont\bfseries #1}
    \if@titlepage
      \newenvironment{abstract}{%
          \titlepage
          \null\vfil
          \@beginparpenalty\@lowpenalty
          \begin{center}%
            \bfseries \abstractname
            \@endparpenalty\@M
          \end{center}}%
         {\par\vfil\null\endtitlepage}
    \else
      \newenvironment{abstract}{%
          \if@twocolumn
            \section*{\abstractname}%
          \else
            \small
            \begin{center}%
              {\bfseries \abstractname\vspace{-.5em}\vspace{\z@}}%
            \end{center}%
            \quotation
          \fi}
          {\if@twocolumn\else\endquotation\fi}
    \fi
    \newenvironment{verse}
                   {\let\\\@centercr
                    \list{}{\itemsep      \z@
                            \itemindent   -1.5em%
                            \listparindent\itemindent
                            \rightmargin  \leftmargin
                            \advance\leftmargin 1.5em}%
                    \item\relax}
                   {\endlist}
    \newenvironment{quotation}
                   {\list{}{\listparindent 1.5em%
                            \itemindent    \listparindent
                            \rightmargin   \leftmargin
                            \parsep        \z@ \@plus\p@}%
                    \item\relax}
                   {\endlist}
    \newenvironment{quote}
                   {\list{}{\rightmargin\leftmargin}%
                    \item\relax}
                   {\endlist}
    \if@compatibility
      \newenvironment{titlepage}
        {%
          \if@twocolumn
            \@restonecoltrue\onecolumn
          \else
            \@restonecolfalse\newpage
          \fi
          \thispagestyle{empty}%
          \setcounter{page}\z@
        }%
        {\if@restonecol\twocolumn \else \newpage \fi
        }
    \else
      \newenvironment{titlepage}
        {%
          \if@twocolumn
            \@restonecoltrue\onecolumn
          \else
            \@restonecolfalse\newpage
          \fi
          \thispagestyle{empty}%
          \setcounter{page}\@ne
        }%
        {\if@restonecol\twocolumn \else \newpage \fi
         \if@twoside\else
            \setcounter{page}\@ne
         \fi
        }
    \fi
    \newcommand\appendix{\par
      \setcounter{section}{0}%
      \setcounter{subsection}{0}%
      \gdef\thesection{\@Alph\c@section}}
    \setlength\arraycolsep{5\p@}
    \setlength\tabcolsep{6\p@}
    \setlength\arrayrulewidth{.4\p@}
    \setlength\doublerulesep{2\p@}
    \setlength\tabbingsep{\labelsep}
    \skip\@mpfootins = \skip\footins
    \setlength\fboxsep{3\p@}
    \setlength\fboxrule{.4\p@}
    \renewcommand \theequation {\@arabic\c@equation}
    \newcounter{figure}
    \renewcommand \thefigure {\@arabic\c@figure}
    \def\fps@figure{tbp}
    \def\ftype@figure{1}
    \def\ext@figure{lof}
    \def\fnum@figure{\figurename\nobreakspace\thefigure}
    \newenvironment{figure}
                   {\@float{figure}}
                   {\end@float}
    \newenvironment{figure*}
                   {\@dblfloat{figure}}
                   {\end@dblfloat}
    \newcounter{table}
    \renewcommand\thetable{\@arabic\c@table}
    \def\fps@table{tbp}
    \def\ftype@table{2}
    \def\ext@table{lot}
    \def\fnum@table{\tablename\nobreakspace\thetable}
    \newenvironment{table}
                   {\@float{table}}
                   {\end@float}
    \newenvironment{table*}
                   {\@dblfloat{table}}
                   {\end@dblfloat}
    \newlength\abovecaptionskip
    \newlength\belowcaptionskip
    \setlength\abovecaptionskip{10\p@}
    \setlength\belowcaptionskip{0\p@}
    \long\def\@makecaption#1#2{%
      \vskip\abovecaptionskip
      \sbox\@tempboxa{#1: #2}%
      \ifdim \wd\@tempboxa >\hsize
        #1: #2\par
      \else
        \global \@minipagefalse
        \hb@xt@\hsize{\hfil\box\@tempboxa\hfil}%
      \fi
      \vskip\belowcaptionskip}
    \DeclareOldFontCommand{\rm}{\normalfont\rmfamily}{\mathrm}
    \DeclareOldFontCommand{\sf}{\normalfont\sffamily}{\mathsf}
    \DeclareOldFontCommand{\tt}{\normalfont\ttfamily}{\mathtt}
    \DeclareOldFontCommand{\bf}{\normalfont\bfseries}{\mathbf}
    \DeclareOldFontCommand{\it}{\normalfont\itshape}{\mathit}
    \DeclareOldFontCommand{\sl}{\normalfont\slshape}{\@nomath\sl}
    \DeclareOldFontCommand{\sc}{\normalfont\scshape}{\@nomath\sc}
    \DeclareRobustCommand*\cal{\@fontswitch\relax\mathcal}
    \DeclareRobustCommand*\mit{\@fontswitch\relax\mathnormal}
    \newcommand\@pnumwidth{1.55em}
    \newcommand\@tocrmarg{2.55em}
    \newcommand\@dotsep{4.5}
    \setcounter{tocdepth}{3}
    \newcommand\tableofcontents{%
        \section*{\contentsname
            \@mkboth{%
               \MakeUppercase\contentsname}{\MakeUppercase\contentsname}}%
        \@starttoc{toc}%
        }
    \newcommand*\l@part[2]{%
      \ifnum \c@tocdepth >-2\relax
        \addpenalty\@secpenalty
        \addvspace{2.25em \@plus\p@}%
        \setlength\@tempdima{3em}%
        \begingroup
          \parindent \z@ \rightskip \@pnumwidth
          \parfillskip -\@pnumwidth
          {\leavevmode
           \large \bfseries #1\hfil
           \hb@xt@\@pnumwidth{\hss #2%
                              \kern-\p@\kern\p@}}\par
           \nobreak
           \if@compatibility
             \global\@nobreaktrue
             \everypar{\global\@nobreakfalse\everypar{}}%
          \fi
        \endgroup
      \fi}
    \newcommand*\l@section[2]{%
      \ifnum \c@tocdepth >\z@
        \addpenalty\@secpenalty
        \addvspace{1.0em \@plus\p@}%
        \setlength\@tempdima{1.5em}%
        \begingroup
          \parindent \z@ \rightskip \@pnumwidth
          \parfillskip -\@pnumwidth
          \leavevmode \bfseries
          \advance\leftskip\@tempdima
          \hskip -\leftskip
          #1\nobreak\hfil
          \nobreak\hb@xt@\@pnumwidth{\hss #2%
                                     \kern-\p@\kern\p@}\par
        \endgroup
      \fi}
    \newcommand*\l@subsection{\@dottedtocline{2}{1.5em}{2.3em}}
    \newcommand*\l@subsubsection{\@dottedtocline{3}{3.8em}{3.2em}}
    \newcommand*\l@paragraph{\@dottedtocline{4}{7.0em}{4.1em}}
    \newcommand*\l@subparagraph{\@dottedtocline{5}{10em}{5em}}
    \newcommand\listoffigures{%
        \section*{\listfigurename}%
          \@mkboth{\MakeUppercase\listfigurename}%
                  {\MakeUppercase\listfigurename}%
        \@starttoc{lof}%
        }
    \newcommand*\l@figure{\@dottedtocline{1}{1.5em}{2.3em}}
    \newcommand\listoftables{%
        \section*{\listtablename}%
          \@mkboth{%
              \MakeUppercase\listtablename}%
             {\MakeUppercase\listtablename}%
        \@starttoc{lot}%
        }
    \let\l@table\l@figure
    \newdimen\bibindent
    \setlength\bibindent{1.5em}
    \newenvironment{thebibliography}[1]
         {\section*{\refname}%
          \@mkboth{\MakeUppercase\refname}{\MakeUppercase\refname}%
          \list{\@biblabel{\@arabic\c@enumiv}}%
               {\settowidth\labelwidth{\@biblabel{#1}}%
                \leftmargin\labelwidth
                \advance\leftmargin\labelsep
                \@openbib@code
                \usecounter{enumiv}%
                \let\p@enumiv\@empty
                \renewcommand\theenumiv{\@arabic\c@enumiv}}%
          \sloppy
          \clubpenalty4000
          \@clubpenalty \clubpenalty
          \widowpenalty4000%
          \sfcode`\.\@m}
         {\def\@noitemerr
           {\@latex@warning{Empty `thebibliography' environment}}%
          \endlist}
    \newcommand\newblock{\hskip .11em\@plus.33em\@minus.07em}
    \let\@openbib@code\@empty
    \newenvironment{theindex}
                   {\if@twocolumn
                      \@restonecolfalse
                    \else
                      \@restonecoltrue
                    \fi
                    \twocolumn[\section*{\indexname}]%
                    \@mkboth{\MakeUppercase\indexname}%
                            {\MakeUppercase\indexname}%
                    \thispagestyle{plain}\parindent\z@
                    \parskip\z@ \@plus .3\p@\relax
                    \columnseprule \z@
                    \columnsep 35\p@
                    \let\item\@idxitem}
                   {\if@restonecol\onecolumn\else\clearpage\fi}
    \newcommand\@idxitem{\par\hangindent 40\p@}
    \newcommand\subitem{\@idxitem \hspace*{20\p@}}
    \newcommand\subsubitem{\@idxitem \hspace*{30\p@}}
    \newcommand\indexspace{\par \vskip 10\p@ \@plus5\p@ \@minus3\p@\relax}
    \renewcommand\footnoterule{%
      \kern-3\p@
      \hrule\@width.4\columnwidth
      \kern2.6\p@}
    \newcommand\@makefntext[1]{%
        \parindent 1em%
        \noindent
        \hb@xt@1.8em{\hss\@makefnmark}#1}
    \newcommand\contentsname{Contents}
    \newcommand\listfigurename{List of Figures}
    \newcommand\listtablename{List of Tables}
    \newcommand\refname{References}
    \newcommand\indexname{Index}
    \newcommand\figurename{Figure}
    \newcommand\tablename{Table}
    \newcommand\partname{Part}
    \newcommand\appendixname{Appendix}
    \newcommand\abstractname{Abstract}
    \def\today{\ifcase\month\or
      January\or February\or March\or April\or May\or June\or
      July\or August\or September\or October\or November\or December\fi
      \space\number\day, \number\year}
    \setlength\columnsep{10\p@}
    \setlength\columnseprule{0\p@}
    \pagestyle{plain}
    \pagenumbering{arabic}
    \if@twoside
    \else
      \raggedbottom
    \fi
    \if@twocolumn
      \twocolumn
      \sloppy
      \flushbottom
    \else
      \onecolumn
    \fi
%% End of file `article.cls'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Useful packages
    \RequirePackage{xparse}
    \RequirePackage{etoolbox}
    \RequirePackage{xkeyval}
    \RequirePackage{calc}
    \RequirePackage{array}
    \RequirePackage{graphicx}
    \RequirePackage{xspace}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Metadata
    \makeatletter
        \csdef{CAutName}{}                      \define@key{docu}{AutName}{\csdef{CAutName}{#1}}
        \csdef{CAutFunc}{}                      \define@key{docu}{AutFunction}{\csdef{CAutFunc}{#1}}
        \csdef{CAutDate}{}                      \define@key{docu}{AutDate}{\csdef{CAutDate}{#1}}
        \csdef{CAppName}{}                      \define@key{docu}{AppName}{\csdef{CAppName}{#1}}
        \csdef{CAppFunc}{}                      \define@key{docu}{AppFunction}{\csdef{CAppFunc}{#1}}
        \csdef{CAppDate}{}                      \define@key{docu}{AppDate}{\csdef{CAppDate}{#1}}
        \csdef{CDocuProject}{}                  \define@key{docu}{Project}{\csdef{CDocuProject}{#1}}
        \csdef{CDocuName}{}                     \define@key{docu}{DocuName}{\csdef{CDocuName}{#1}}
        \csdef{CDocuRev}{}                      \define@key{docu}{Rev}{\csdef{CDocuRev}{#1}}
        %
        \csdef{CDocuTitle}{}                    \define@key{docu}{Title}{\csdef{CDocuTitle}{#1}}
        \csdef{CDocuSubTitle}{}                 \define@key{docu}{Subtitle}{\csdef{CDocuSubTitle}{#1}}
        \csdef{CDocuHeadTitle}{}                \define@key{docu}{HeadTitle}{\csdef{CDocuHeadTitle}{#1}}
        \csdef{CDocuConducted}{}\csdef{authorname}{}\define@key{docu}{Conducted}{\csdef{CDocuConducted}{#1}\csdef{authorname}{#1}}
        \csdef{CDocuDate}{}\csdef{reportdate}{} \define@key{docu}{Date}{\csdef{CDocuDate}{#1}\csdef{reportdate}{#1}}
        \csdef{CDocuDisclaimer}{The names of IT'IS and any of the researchers involved may be mentioned only in connection with statements or results from this report. The mention of names to third parties other than certification bodies may be done so only after written approval from Prof. Dr. N. Kuster.}
        \define@key{docu}{Disclaimer}{\csdef{CDocuDisclaimer}{#1}}
        \csdef{CDocuConfidential}{Confidential} \define@key{docu}{Confidential}{\csdef{CDocuConfidential}{#1}}
        %
        \csdef{customer}{}                      \define@key{docu}{Customer}{\csdef{customer}{#1\xspace}}
        \csdef{CDocuWatermark}{}                \define@key{docu}{Watermark}{\csdef{CDocuWatermark}{#1}}
    \makeatother
    \setkeys{docu}{}
    \newcommand{\DocuMetadata}[1]{\setkeys{docu}{#1}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Layout
    \RequirePackage{geometry}
    \geometry{left=2cm,right=2cm,bottom=3cm,top=3cm}
    \setlength{\parindent}{0pt}
    \setlength{\parskip}{\baselineskip}
    \setlength{\headheight}{13.6pt}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Language
    \RequirePackage[english]{babel}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Headers
    \RequirePackage{fancyhdr}
    \renewcommand{\footrulewidth}{0pt}
    \renewcommand{\headrulewidth}{0.5pt}
    \fancypagestyle{main}{
         %\cfoot{\textbf{\CDocuConfidential}}
         \lhead[\thepage]{\ifcsstring{CDocuHeadTitle}{}{\CDocuTitle}{\CDocuHeadTitle}}
         \rhead[\ifcsstring{CDocuHeadTitle}{}{\CDocuTitle}{\CDocuHeadTitle}]{\thepage}
    }
    \pagestyle{main}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Font
    \RequirePackage{mathptmx}
    \RequirePackage[T1]{fontenc}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphic packages
    \RequirePackage{xcolor}
    \RequirePackage{tikz}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Floats
    \RequirePackage{float}
    \RequirePackage{caption}
    \RequirePackage{subcaption}
    \RequirePackage{placeins}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tables
    \RequirePackage{booktabs}
    \RequirePackage{tabularx}
    \RequirePackage{longtable}
    \RequirePackage{multirow}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% List
    \RequirePackage{enumitem}
    \setlist{nosep,noitemsep}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Science
    \RequirePackage{amsmath}
    \IfFileExists{siunitx.sty}{%
        \RequirePackage{siunitx}%
        \sisetup{range-phrase=\text{--},range-units=single}%
    }{}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hyperref
    \IfFileExists{xurl.sty}{\RequirePackage{xurl}}{}
    \RequirePackage{hyperref}
    \RequirePackage{cleveref}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bibliography
    % \RequirePackage{biblatex}  % cite
    % \bibliographystyle{IEEE}
    % \newcommand{\PrintBibliography}[1]{\clearpage
    %     {\small
    %     \addcontentsline{toc}{section}{References}
    %     \bibliography{#1}
    %     }
    % }
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Table fo contents
    \let\OLDtoc\tableofcontents
    \renewcommand{\tableofcontents}{
        \clearpage
        \begingroup
        \setlength{\parskip}{0pt}
        \OLDtoc
        \endgroup
        \clearpage
    }
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cover page
    \newcommand{\PAGEcover}{\thispagestyle{empty}
        \vspace*{-4\baselineskip}
        \begin{tabular}{|
        >{\centering\arraybackslash}m{0.36\linewidth-2\tabcolsep-2\arrayrulewidth}|
        >{\centering\arraybackslash}m{0.20\linewidth-2\tabcolsep-2\arrayrulewidth}|
        >{\centering\arraybackslash}m{0.26\linewidth-2\tabcolsep-2\arrayrulewidth}|
        >{\centering\arraybackslash}m{0.18\linewidth-2\tabcolsep-2\arrayrulewidth}|}
            \hline
            \rule[-4pt]{0pt}{46pt}\includegraphics[width=\linewidth]{\PATHCLASS/itis-foundation.jpg} &
            Project\par\strut\par\bfseries\CDocuProject&
            Document Name\par\strut\par\bfseries \CDocuName&
            Rev.\par\strut\par\bfseries\CDocuRev\\
            \hline
        \end{tabular}

        \vspace{3\baselineskip}
        \begin{center}\bfseries\Large
            \CDocuTitle
        \end{center}

        \vfill
        \begingroup\renewcommand{\arraystretch}{2}
            \begin{tabular}{|
        >{\raggedright\arraybackslash}m{0.12\linewidth-2\tabcolsep-2\arrayrulewidth}|
        >{\raggedright\arraybackslash}m{0.20\linewidth-2\tabcolsep-2\arrayrulewidth}|
        >{\raggedright\arraybackslash}m{0.24\linewidth-2\tabcolsep-2\arrayrulewidth}|
        >{\raggedright\arraybackslash}m{0.17\linewidth-2\tabcolsep-2\arrayrulewidth}|
        >{\raggedright\arraybackslash}m{0.27\linewidth-2\tabcolsep-2\arrayrulewidth}|
        }
            \hline
                               & \bfseries Name & \bfseries Function & \bfseries Date & \bfseries Signature \\ \hline
            \bfseries Author   & \CAutName      & \CAutFunc          & \CAutDate      &                     \\ \hline
            \bfseries Approval & \CAppName      & \CAppFunc          & \CAppDate      &                     \\ \hline
        \end{tabular}
        \endgroup
        \clearpage
    }
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title page
    \newcommand{\PAGEtitle}{\enlargethispage{3\baselineskip}\thispagestyle{empty}
        \vspace*{-6\baselineskip}
        \includegraphics[width=\linewidth]{\PATHCLASS/ITIS_header.png}

        \vspace{9\baselineskip}
        \begin{center}
            {\Large\CDocuSubTitle}

            \vspace{\baselineskip}
            \begin{minipage}{\linewidth}\centering\LARGE\bfseries
                \CDocuTitle
            \end{minipage}

            \ifcsstring{CDocuConducted}{}{}{
            \vspace{2\baselineskip}
            conducted by\\[\baselineskip]
            \begin{minipage}{\linewidth}\centering\Large
            \CDocuConducted
            \end{minipage}}
        \end{center}

        \vfill
        \begin{center}
            \strut\CDocuDate
        \end{center}

        \vspace{2\baselineskip}
        %\strut\CDocuDisclaimer

        \vspace{2\baselineskip}
        %\begin{center}\bfseries
        %    \strut\CDocuConfidential
        %\end{center}

        \vspace{2\baselineskip}
        \includegraphics[width=\linewidth]{\PATHCLASS/ITIS_footer.png}
        \clearpage
    }
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Watermark
    \RequirePackage{draftwatermark}
    \SetWatermarkText{\CDocuWatermark}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Footnote
    \RequirePackage[hang,flushmargin]{footmisc}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% At begin document
    \AfterEndPreamble{%
        \ifbool{cover}{\PAGEcover}{}%
        \setcounter{page}{1}
        \ifbool{titlepage}{\PAGEtitle}{}%
    }
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\endinput
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%