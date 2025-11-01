; extends

(block_mapping
  ;; 1) task: ...
  (block_mapping_pair
    key: (flow_node) @task_key
    value: (_))
  (#match? @task_key "[tT][aA][sS][kK]")
  ;; 2) ...
  ;; 3) then inputs:
  (block_mapping_pair
    key: (flow_node) @inputs_key
    (#match? @inputs_key "[iI][nN][pP][uU][tT][sS]")
    value: (block_node
      (block_mapping
        ;; 4) inside inputs: scriptType: inlineScript
        (block_mapping_pair
          key: (flow_node) @stype_key
          (#match? @stype_key "[sS][cC][rR][iI][pP][tT][tT][yY][pP][eE]")
          value: (flow_node) @stype_val)
          (#match? @stype_val "[iI][nN][lL][iI][nN][eE][sS][cC][rR][iI][pP][tT]")
        ;; 5) later: inline: |  <block>
        (block_mapping_pair
          key: (flow_node) @inline_key
          (#match? @inline_key "[iI][nN][lL][iI][nN][eE]")
          value: (block_node
            (block_scalar) @injection.content
            (#set! injection.language "ps1")
            ;; trim off the first character so '|' never reaches ps1
            (#offset! @injection.content 0 1 0 0)))))))

(block_mapping_pair
  key: (flow_node) @key
  (#match? @key "[pP][oO][wW][eE][rR][sS][hH][eE][lL][lL]|[pP][wW][sS][hH]")
  value: (block_node
    (block_scalar) @injection.content
    (#set! injection.language "ps1")
    ;; trim off the first character so '|' never reaches ps1
    (#offset! @injection.content 0 1 0 0)))

(block_mapping_pair
  key: (flow_node) @key
  (#match? @key "[bB][aA][sS][hH]")
  value: (block_node
    (block_scalar) @injection.content
    (#set! injection.language "bash")
    ;; trim off the first character so '|' never reaches ps1
    (#offset! @injection.content 0 1 0 0)))
