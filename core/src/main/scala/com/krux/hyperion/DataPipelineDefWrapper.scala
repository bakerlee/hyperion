package com.krux.hyperion

import com.krux.hyperion.expression.Parameter

/**
  * DataPipelineDefWrapper provides a way to wrap other DataPipelineDefs
  * in order to override aspects.
  */
private[hyperion] case class DataPipelineDefWrapper(
  override val hc: HyperionContext,
  override val pipelineName: String,
  schedule: Schedule,
  workflowFunc: () => WorkflowExpression,
  override val tags: Map[String, Option[String]],
  override val parameters: Iterable[Parameter[_]]
) extends DataPipelineDef {

  def withName(name: String) = copy(pipelineName = name)
  def withSchedule(schedule: Schedule) = copy(schedule = schedule)
  def withTags(tags: Map[String, Option[String]]) = copy(tags = this.tags ++ tags)
  def withParameters(parameters: Iterable[Parameter[_]]) = copy(parameters = parameters)

  def workflow = workflowFunc()

}

object DataPipelineDefWrapper {
  def apply(inner: DataPipelineDef): DataPipelineDefWrapper = DataPipelineDefWrapper(
    inner.hc,
    inner.pipelineName,
    inner.schedule,
    () => inner.workflow,
    inner.tags,
    inner.parameters
  )
}
