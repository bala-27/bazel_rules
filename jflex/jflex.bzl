# Copyright (C) 2018 Google LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
""" Skylark rules for JFlex. """

def _jflex_impl(ctx):
    """ Generates a Java lexer from a lex definition, using JFlex. """

    # Output directory is bazel-genfiles/package, regardless of Java package defined in
    # the grammar
    output_dir = "/".join(
        [ctx.configuration.genfiles_dir.path, ctx.label.package],
    )

    # TODO(regisd): Add support for JFlex options.
    maybe_skel = [ctx.file.skeleton] if ctx.file.skeleton else []
    cmd_maybe_skel = ["-skel", ctx.file.skeleton.path] if ctx.file.skeleton else []
    arguments = (
        cmd_maybe_skel +
        # Option to specify output directory
        ["-d", output_dir] +
        # Input files
        [f.path for f in ctx.files.srcs]
    )
    ctx.actions.run(
        mnemonic = "jflex",
        inputs = ctx.files.srcs + maybe_skel,
        outputs = ctx.outputs.outputs,
        executable = ctx.executable.jflex_bin,
        arguments = arguments,
    )
    print("jflex " + (" ".join(arguments)))

jflex = rule(
    implementation = _jflex_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_empty = False,
            allow_files = True,
            mandatory = True,
            doc = "a list of grammar specifications",
        ),
        "skeleton": attr.label(
            allow_files = True,
            single_file = True,
            doc = "an optional skeleton",
        ),
        "outputs": attr.output_list(allow_empty = False),
        "jflex_bin": attr.label(
            default = Label("//jflex:jflex_bin"),
            executable = True,
            cfg = "host",
            doc = "the java_binary of JFlex",
        ),
    },
    output_to_genfiles = True,  # JFlex generates java files, not bin files
)
